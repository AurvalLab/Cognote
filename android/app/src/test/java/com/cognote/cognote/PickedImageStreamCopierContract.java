package com.cognote.cognote;

import java.util.Arrays;

public final class PickedImageStreamCopierContract {
    private PickedImageStreamCopierContract() {}

    public static void main(String[] args) throws Exception {
        assertOperationFailure(
                "unreadable",
                () -> PickedImageStreamCopier.fromProvider(
                        () -> { throw new Exception("provider open failed"); }));
        assertOperationFailure(
                "storage",
                () -> PickedImageStreamCopier.onCacheTarget(
                        () -> { throw new Exception("cache create failed"); }));
        assertCopiesAndSyncs();
        assertFailure("unreadable", new FakeSource(Failure.READ), new FakeTarget(Failure.NONE), 4);
        assertFailure("unreadable", new FakeSource(Failure.CLOSE), new FakeTarget(Failure.NONE), 4);
        assertFailure("storage", new FakeSource(Failure.NONE), new FakeTarget(Failure.WRITE), 4);
        assertFailure("storage", new FakeSource(Failure.NONE), new FakeTarget(Failure.SYNC), 4);
        assertFailure("storage", new FakeSource(Failure.NONE), new FakeTarget(Failure.CLOSE), 4);
        assertFailure("too_large", new FakeSource(Failure.NONE), new FakeTarget(Failure.NONE), 2);
    }

    private static void assertOperationFailure(String expected, FailureOperation operation)
            throws Exception {
        try {
            operation.run();
            throw new AssertionError("expected " + expected);
        } catch (PickedImageStreamCopier.CopyFailure error) {
            if (!expected.equals(error.code)) {
                throw new AssertionError("expected " + expected + " but got " + error.code);
            }
        }
    }

    private static void assertCopiesAndSyncs() throws Exception {
        final FakeSource source = new FakeSource(Failure.NONE);
        final FakeTarget target = new FakeTarget(Failure.NONE);
        final long copied = PickedImageStreamCopier.copy(source, target, 4);
        if (copied != 4L || !target.synced || !target.closed || !source.closed) {
            throw new AssertionError("happy path did not copy, sync, and close both sides");
        }
        if (!Arrays.equals(target.written, new byte[] {1, 2, 3, 4})) {
            throw new AssertionError("copied bytes changed");
        }
    }

    private static void assertFailure(
            String expected,
            FakeSource source,
            FakeTarget target,
            long maxBytes) throws Exception {
        try {
            PickedImageStreamCopier.copy(source, target, maxBytes);
            throw new AssertionError("expected " + expected);
        } catch (PickedImageStreamCopier.CopyFailure error) {
            if (!expected.equals(error.code)) {
                throw new AssertionError("expected " + expected + " but got " + error.code);
            }
        }
    }

    private enum Failure { NONE, READ, WRITE, SYNC, CLOSE }

    private interface FailureOperation {
        void run() throws Exception;
    }

    private static final class FakeSource implements PickedImageStreamCopier.Source {
        private final Failure failure;
        private boolean read;
        private boolean closed;

        FakeSource(Failure failure) {
            this.failure = failure;
        }

        @Override
        public int read(byte[] buffer) throws Exception {
            if (failure == Failure.READ) {
                throw new Exception("provider read failed");
            }
            if (read) {
                return -1;
            }
            read = true;
            buffer[0] = 1;
            buffer[1] = 2;
            buffer[2] = 3;
            buffer[3] = 4;
            return 4;
        }

        @Override
        public void close() throws Exception {
            closed = true;
            if (failure == Failure.CLOSE) {
                throw new Exception("provider close failed");
            }
        }
    }

    private static final class FakeTarget implements PickedImageStreamCopier.Target {
        private final Failure failure;
        private byte[] written = new byte[0];
        private boolean synced;
        private boolean closed;

        FakeTarget(Failure failure) {
            this.failure = failure;
        }

        @Override
        public void write(byte[] buffer, int offset, int length) throws Exception {
            if (failure == Failure.WRITE) {
                throw new Exception("cache write failed");
            }
            written = Arrays.copyOfRange(buffer, offset, offset + length);
        }

        @Override
        public void sync() throws Exception {
            synced = true;
            if (failure == Failure.SYNC) {
                throw new Exception("cache sync failed");
            }
        }

        @Override
        public void close() throws Exception {
            closed = true;
            if (failure == Failure.CLOSE) {
                throw new Exception("cache close failed");
            }
        }
    }
}
