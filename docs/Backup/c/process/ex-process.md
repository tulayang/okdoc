process.c
---------

```
#include <unistd.h>
#include <wait.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {

/***************************** fork 进程 *****************************/

	pid_t pid = fork();

	if (pid == -1) {
		printf("ERROR: process fork error!\n");
		exit(0);
	}

/***************************** 转入子进程 *****************************/

	char *child_argv[] = { "Hello", "world" };
	char *child_envp[] = {};

	if (pid == 0) {
		execve("process-worker", child_argv, child_envp);
	}

/***************************** 转入主进程 *****************************/

	int status;
	/* wait(NULL); */
	waitpid(pid, &status, 0);
	printf("Master: master %d, worker %d, return status %d.\n", getpid(), pid, status);

	return 0;
}
```
process-worker.c
-----------------

```
#include <unistd.h>
#include <stdio.h>

int main(int argc, char** argv) {
	printf("Worker: worker %d online，argv %s %s.\n", getpid(), argv[0], argv[1]);
	sleep(3);
	printf("Worker: worker %d done.\n", getpid());
	return 0;
}
```