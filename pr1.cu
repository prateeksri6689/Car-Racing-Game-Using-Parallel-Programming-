#include<stdio.h>
#include<cuda.h>
#include <stdlib.h>
#include <iostream>
#include <time.h>
#include <math.h>

#define N 100000
using namespace std;
static const long BLK_SIZE =1000 ;
#define CUDA_CHECK_RETURN(value) {											\
	cudaError_t _m_cudaStat = value;										\
	if (_m_cudaStat != cudaSuccess) {										\
		fprintf(stderr, "Error %s at line %d in file %s\n",					\
				cudaGetErrorString(_m_cudaStat), __LINE__, __FILE__);		\
		exit(1);															\
	} }



__global__ void sort(int *c,int *count)
{
    int l;
    if(*count%2==0)
          l=*count/2;
    else
         l=(*count/2)+1;
    for(int i=0;i<l;i++)
    {
            if(threadIdx.x%2==0)  //even phase
            {
                if(c[threadIdx.x]>c[threadIdx.x+1])
                {
                    int temp=c[threadIdx.x];
                    c[threadIdx.x]=c[threadIdx.x+1];
                    c[threadIdx.x+1]=temp;
                }

            __syncthreads();
            }
            else     //odd phase
            {
                if(c[threadIdx.x]>c[threadIdx.x+1])
                {
                    int temp=c[threadIdx.x];
                    c[threadIdx.x]=c[threadIdx.x+1];
                    c[threadIdx.x+1]=temp;
                }

            __syncthreads();
            }
    }

}

void swap(int *xp, int *yp)
{
	int temp = *xp;
	*xp = *yp;
	*yp = temp;
}

// An optimized version of Bubble Sort
void bubbleSort(int arr[], int n)
{

}

int main()
{
int a[N],b[N];
    for (int i = 0; i < N; i++) {
  		a[i] = (float) rand() / (float) RAND_MAX * 100;

  	}


  printf("ORIGINAL ARRAY : \n");
  for(int i=0;i<N;i++)
          {

          printf("%d ",a[i]);
          }


  int *c,*count;
  int k=N;


  cudaMalloc((void**)&c,sizeof(int)*N);
  cudaMalloc((void**)&count,sizeof(int));
  cudaMemcpy(c,&a,sizeof(int)*N,cudaMemcpyHostToDevice);
  cudaMemcpy(count,&k,sizeof(int),cudaMemcpyHostToDevice);


  //Time kernel launch
  	//Time kernel launch
  	cudaEvent_t start, stop;
  	CUDA_CHECK_RETURN(cudaEventCreate(&start));
  	CUDA_CHECK_RETURN(cudaEventCreate(&stop));
  	float elapsedTime;

  	CUDA_CHECK_RETURN(cudaEventRecord(start, 0));



  sort<<< ceil(N/(float)BLK_SIZE),BLK_SIZE >>>(c,count);

  CUDA_CHECK_RETURN(cudaEventRecord(stop, 0));

  	CUDA_CHECK_RETURN(cudaEventSynchronize(stop));
  	CUDA_CHECK_RETURN(cudaEventElapsedTime(&elapsedTime, start, stop));
  	CUDA_CHECK_RETURN(cudaThreadSynchronize());	// Wait for the GPU launched work to complete
  	CUDA_CHECK_RETURN(cudaGetLastError()); //Check if an error occurred in device code
  	CUDA_CHECK_RETURN(cudaEventDestroy(start));
  	CUDA_CHECK_RETURN(cudaEventDestroy(stop));
  	cout << "done.\nElapsed kernel time: " << elapsedTime << " ms\n";

  	cout << "Copying results back to host .... "<<endl;

  cudaMemcpy(&b,c,sizeof(int)*N,cudaMemcpyDeviceToHost);
  printf("\nSORTED ARRAY : \n");

  for(int i=0;i<N;i++)
      {
         printf("%d ",b[i]);
      }

  //Add code to time host calculations
  	clock_t st, ed;

  	st = clock();
  	//bool valid = true;

  //bubbleSort(a,N);

  	int i, j;
  	bool swapped;
  	for (i = 0; i < N-1; i++)
  	{
  		swapped = false;
  		for (j = 0; j < N-i-1; j++)
  		{
  			if (a[j] > a[j+1])
  			{
  			swap(&a[j], &a[j+1]);
  			swapped = true;
  			}
  		}

  		// IF no two elements were swapped by inner loop, then break
  		if (swapped == false)
  			break;
  	}

  printf("\n");
        printf("BYCPU");
        printf("\n");
  for(int i=0;i<N;i++)
        {

	  printf("%d ",a[i]);
        }
  ed = clock() - st;
  	cout << "Elapsed time on host: " << ((float) ed) / CLOCKS_PER_SEC * 1000
  			<< " ms" << endl;

}



