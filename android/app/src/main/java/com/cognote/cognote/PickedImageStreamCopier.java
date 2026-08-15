package com.cognote.cognote;

final class PickedImageStreamCopier {
    interface Operation<T> {
        T run() throws Exception;
    }

    interface Source {
        int read(byte[] buffer) throws Exception;

        void close() throws Exception;
    }

    interface Target {
        void write(byte[] buffer, int offset, int length) throws Exception;

        void sync() throws Exception;

        void close() throws Exception;
    }

    static final class CopyFailure extends Exception {
        final String code;

        CopyFailure(String code) {
            this.code = code;
        }
    }

    private PickedImageStreamCopier() {}

    static <T> T fromProvider(Operation<T> operation) throws CopyFailure {
        try {
            return operation.run();
        } catch (Exception error) {
            throw new CopyFailure("unreadable");
        }
    }

    static <T> T onCacheTarget(Operation<T> operation) throws CopyFailure {
        try {
            return operation.run();
        } catch (Exception error) {
            throw new CopyFailure("storage");
        }
    }

    static long copy(Source source, Target target, long maxBytes) throws CopyFailure {
        final byte[] buffer = new byte[8192];
        long total = 0L;
        CopyFailure failure = null;
        while (failure == null) {
            final int read;
            try {
                read = source.read(buffer);
            } catch (Exception error) {
                failure = new CopyFailure("unreadable");
                break;
            }
            if (read < 0) {
                break;
            }
            total += read;
            if (total > maxBytes) {
                failure = new CopyFailure("too_large");
                break;
            }
            try {
                target.write(buffer, 0, read);
            } catch (Exception error) {
                failure = new CopyFailure("storage");
            }
        }
        if (failure == null) {
            try {
                target.sync();
            } catch (Exception error) {
                failure = new CopyFailure("storage");
            }
        }
        try {
            target.close();
        } catch (Exception error) {
            if (failure == null) {
                failure = new CopyFailure("storage");
            }
        }
        try {
            source.close();
        } catch (Exception error) {
            if (failure == null) {
                failure = new CopyFailure("unreadable");
            }
        }
        if (failure != null) {
            throw failure;
        }
        return total;
    }
}
