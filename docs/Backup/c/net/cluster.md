MPICH
-----

并行编程是一个发展相当完善的领域，在过去 20 年中，已经开发出了多种编程平台和标准。

HPC 中使用的两种主要的硬件平台是共享内存系统和分布式内存系统。详细信息请参阅 第 1 部分。

在共享内存系统中，High Performance FORTRAN 是一种非常适合并行编程的语言。它可以有效地利用数据的并行，并将其作为一个整体数组在不同处理器上使用不同的索引来同时执行指令。因此，这只需要最少的努力就可以提供自动的并行处理能力。（Jamaica 项目就是这样一个例子，标准的 Java 程序可以使用特殊的编译器进行重构来生成多线程的代码。然后所生成的代码就可以自动利用 SMP 体系架构的优点，并可以并行执行了。）

在分布式内存系统上，情况会有根本的不同，这是因为内存是分布式的；必须编写能够理解硬件底层的分布式特性的代码，并且需要显式地使用消息传递在不同的节点之间交换信息。并行虚拟机（PVM）曾经是一个非常流行的并行编程平台，但是最近 MPI 已经成为了为集群编写并行程序的事实标准。

为 Linux 上 FORTRAN、C 和 C++ 使用的高质量的 MPI 实现可以免费获得。流行的 MPI 实现有两个：

* MPICH
* LAM/MPI


Example
--------

```
/* To compile: "mpicc -g -o matrix matrix.c"
   To run: "mpirun -np 4 matrix"
   -np 4" specifies the number of processors.*/
   
#include <stdio.h>
#include <mpi.h>
#define SIZE 4

int main(int argc, char **argv) {
    int j;
    int rank, size, root = 0;
    float X[SIZE];
    float X1[SIZE];
    float Y1[SIZE];
    float Y[SIZE][SIZE];
    float Z[SIZE];
    float z;

    /* Initialize MPI. */
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    /* Initialize X and Y on root node. Note the row/col alignment. This is specific  to C */
    if (rank == root) {
        Y[0][0] = 1; Y[1][0] = 2; Y[2][0] = 3; Y[3][0] = 4;
        Y[0][1] = 5; Y[1][1] = 6; Y[2][1] = 7; Y[3][1] = 8;
        Y[0][2] = 9; Y[1][2] = 10;Y[2][2] = 11;Y[3][2] = 12;
        Y[0][3] = 13;Y[1][3] = 14;Y[2][3] = 15;Y[3][3] = 16;
        Z[0] = 1;
        Z[1] = 2;
        Z[2] = 3;
        Z[3] = 4;
    }
    MPI_Barrier(MPI_COMM_WORLD);
    /*  root scatters matrix Y in 'SIZE' parts to all nodes as the matrix Y1 */
    MPI_Scatter(Y,SIZE,MPI_FLOAT,Y1,SIZE,MPI_FLOAT,root,MPI_COMM_WORLD);
    /* Z is also scattered to all other nodes from root. Since one element is sent to
      all nodes, a scalar variable z is used. */
    MPI_Scatter(Z,1,MPI_FLOAT,&z,1,MPI_FLOAT, root,MPI_COMM_WORLD);
    /* This step is carried out on all nodes in parallel.*/
    for (j = 0; j < SIZE; j++) {
        X1[j] = z * Y1[j];
    }
    /* Now rows are added, using MPI_SUM (using recursive halving and doubling algorithm,
      internal to the MPI implementation) */
    MPI_Reduce(X1,X,SIZE,MPI_FLOAT,MPI_SUM, root,MPI_COMM_WORLD);
    if (rank == 0) {
        printf("%g\n",X[0]);printf("%g\n",X[1]);printf("%g\n",X[2]);printf("%g\n",X[3]);
    }
    MPI_Finalize();
    return 0;
}
```