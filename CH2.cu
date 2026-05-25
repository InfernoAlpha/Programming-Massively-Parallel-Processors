//notes of chapter 2
#include <stdio.h>

//BaseLine vec_add completely on host device (CPU)
void vec_add_host (float* A_h,float* B_h,float* C_h,int n){
    for(int i = 0;i < n;i++){
        C_h[i] = A_h[i] + B_h[i];
    }
}

/*
cudaMalloc():allocates a block of memory in the device 
Args: Address of a pointer, size in bytes
ex: cudaMalloc((void**)&A_d, size);

cudaFree():free's the allocated memory in the device given a pointer to the memory 
Args: Address of a pointer
ex: cudaFree(A_d)

cudaMemcpy():memory data transfer from a source to target given the source pointer and target pointer 
Args: pointer to destination,pointer to source,number of bytes copied,transfer direction
ex: cudaMemcpy(A_d, A_h, n*sizeof(float), cudaMemcpyHostToDevice)

KernelFunctionName<<< GridDimensions, BlockDimensions >>>(Arguments) 
*/

__global__
void add_kernel(float* A_d,float* B_d,float* C_d,int n){
    int i = blockIdx.x*blockDim.x + threadIdx.x;
    if(i < n){
        C_d[i] = A_d[i] + B_d[i];
    }
}

void vec_add_device(float* A_h,float* B_h,float* C_h,int n){
    float *A_d,*B_d,*C_d;
    
    cudaMalloc((void**)&A_d,n*sizeof(float));
    cudaMalloc((void**)&B_d,n*sizeof(float));
    cudaMalloc((void**)&C_d,n*sizeof(float));

    cudaMemcpy(A_d,A_h,n*sizeof(float),cudaMemcpyHostToDevice);
    cudaMemcpy(B_d,B_h,n*sizeof(float),cudaMemcpyHostToDevice);

    add_kernel<<<ceil(n/256.0), 256>>>(A_d,B_d,C_d,n);

    cudaMemcpy(C_h,C_d,n*sizeof(float),cudaMemcpyDeviceToHost);

    cudaFree(A_d);
    cudaFree(B_d);
    cudaFree(C_d);
}

void main(){
    float A_h[] = {0.1,0.2,0.3};
    float B_h[] = {0.4,0.5,0.6};
    float C_h[3];

    vec_add_device(A_h,B_h,C_h,3);

    for(int i=0;i < 3;i++){
        printf("%f ",C_h[i]);
    }
}