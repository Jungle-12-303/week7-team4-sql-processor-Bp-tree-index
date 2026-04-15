CC = cc
CFLAGS = -std=c11 -Wall -Wextra -pedantic -Iinclude

COMMON_SRCS = \
	src/engine.c \
	src/util.c \
	src/ast.c \
	src/tokenizer.c \
	src/parser.c \
	src/optimizer.c \
	src/storage.c \
	src/executor.c \
	src/database.c \
	src/bptree.c

TARGET = mini_sql
TEST_TARGET = mini_sql_tests
BENCH_TARGET = mini_sql_benchmark
SEED_TARGET = mini_sql_seed
DOCKER_DATA_VOLUME = mini-sql-bptree-data
DOCKER_LOG_VOLUME = mini-sql-bptree-logs

TARGET_SRCS = src/main.c $(COMMON_SRCS)
TEST_SRCS = src/test_main.c $(COMMON_SRCS)
BENCH_SRCS = src/benchmark_main.c $(COMMON_SRCS)
SEED_SRCS = src/seed_main.c $(COMMON_SRCS)

TARGET_OBJS = $(TARGET_SRCS:.c=.o)
TEST_OBJS = $(TEST_SRCS:.c=.o)
BENCH_OBJS = $(BENCH_SRCS:.c=.o)
SEED_OBJS = $(SEED_SRCS:.c=.o)

.PHONY: all clean docker-build docker-test docker-run docker-repl docker-benchmark docker-seed-million

all: $(TARGET) $(TEST_TARGET) $(BENCH_TARGET) $(SEED_TARGET)

$(TARGET): $(TARGET_OBJS)
	$(CC) $(CFLAGS) -o $@ $(TARGET_OBJS)

$(TEST_TARGET): $(TEST_OBJS)
	$(CC) $(CFLAGS) -o $@ $(TEST_OBJS)

$(BENCH_TARGET): $(BENCH_OBJS)
	$(CC) $(CFLAGS) -o $@ $(BENCH_OBJS)

$(SEED_TARGET): $(SEED_OBJS)
	$(CC) $(CFLAGS) -o $@ $(SEED_OBJS)

clean:
	rm -f $(TARGET) $(TEST_TARGET) $(BENCH_TARGET) $(SEED_TARGET) src/*.o

docker-build:
	docker build -t mini-sql-bptree .

docker-test: docker-build
	docker run --rm -v $(DOCKER_LOG_VOLUME):/app/logs mini-sql-bptree ./mini_sql_tests

docker-run: docker-build
	docker run --rm -v $(DOCKER_DATA_VOLUME):/app/runtime_data -v $(DOCKER_LOG_VOLUME):/app/logs mini-sql-bptree ./mini_sql --data-dir /app/runtime_data sql/select_where.sql

docker-repl: docker-build
	docker run --rm -it -v $(DOCKER_DATA_VOLUME):/app/runtime_data -v $(DOCKER_LOG_VOLUME):/app/logs mini-sql-bptree

docker-benchmark: docker-build
	docker run --rm -v $(DOCKER_LOG_VOLUME):/app/logs mini-sql-bptree ./mini_sql_benchmark --rows 1000000 --repetitions 1

docker-seed-million: docker-build
	docker run --rm -v $(DOCKER_DATA_VOLUME):/app/runtime_data -v $(DOCKER_LOG_VOLUME):/app/logs mini-sql-bptree ./mini_sql_seed --data-dir /app/runtime_data --rows 1000000
