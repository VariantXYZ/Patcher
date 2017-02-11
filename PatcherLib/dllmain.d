module dllmain;

import core.sys.windows.windows;
import core.sys.windows.dll;
import core.stdc.string;

import std.algorithm;
import std.exception;
import std.file;
import std.stdio;
import std.string;

__gshared HINSTANCE g_hInst;

extern (Windows)
BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
    switch (ulReason)
    {
        case DLL_PROCESS_ATTACH:
            g_hInst = hInstance;
            dll_process_attach(hInstance, true);
            break;

        case DLL_PROCESS_DETACH:
            dll_process_detach(hInstance, true);
            break;

        case DLL_THREAD_ATTACH:
            dll_thread_attach(true, true);
            break;

        case DLL_THREAD_DETACH:
            dll_thread_detach(true, true);
            break;

        default:
            break;
    }
    return true;
}

void log(T...)(string fmt, T args)
{
    debug
    {
        stdout.writefln(fmt, args);
    }
}

export extern (C) int GetFileCount(const char* directory)
{
	try
	{
		log("GetFileCount: Opening %s", directory);
		return dirEntries(cast(string)fromStringz(directory), "*", SpanMode.breadth).count!(x => x.isFile);
	}
	catch(Exception ex)
	{
		log("Error: %s", ex.msg);
		return -1;
	}
}

export extern (C) void GetFileList(const char* directory, int fileCount, int* fileListLengths, char** fileList)
{
	try
	{
		log("GetFileCount: Opening %s", directory);
		int i = 0;

		if(fileList == null)
			foreach(DirEntry file; dirEntries(cast(string)fromStringz(directory), "*", SpanMode.breadth).filter!(x => x.isFile))
				fileListLengths[i++] = file.name.length+1;
		else
			foreach(DirEntry file; dirEntries(cast(string)fromStringz(directory), "*", SpanMode.breadth).filter!(x => x.isFile))
			{
				memcpy(fileList[i], toStringz(file.name), fileListLengths[i]);
				++i;
			}

		if(i > fileCount)
		{
			throw new Exception(format("Number of files found (%i) is higher than expected file count (%i)", i, fileCount));
		}
	}
	catch(Exception ex)
	{
		log("Error: %s", ex.msg);
	}
}

