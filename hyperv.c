//http://waleedassar.blogspot.com (@waleedassar)
//Detect Hypervisors

#include "windows.h"
#include "stdio.h"

int main(int argc, char* argv[])
{
	bool x=0;
	__asm
	{
        pushad
        pushfd
        pop eax
        or eax,0x00200000
        push eax
        popfd
        pushfd
        pop eax
        and eax,0x00200000
        jz CPUID_NOT_SUPPORTED ;Are you still alive?
        xor eax,eax
        xor edx,edx
        xor ecx,ecx
        xor ebx,ebx
        inc eax ;processor info and feature bits
        cpuid
        test ecx,0x80000000 ;Hypervisor present
        jnz Hypervisor
        mov x,0
        jmp bye
Hypervisor:
        mov x,1
        jmp bye
CPUID_NOT_SUPPORTED:
        mov x,2
bye:
        popad
    }
    if(x==1)
    {
        MessageBox(0,"Hypervisor detected","waliedassar",0);
        ExitProcess(3);
    }
    return 0;
}