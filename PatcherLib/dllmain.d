module dllmain;

import core.sys.windows.windows;
import core.sys.windows.dll;
import core.stdc.string;

import std.algorithm;
import std.exception;
import std.file;
import std.digest.md;
import std.parallelism;
import std.range;
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

// SF94 did it
ubyte[] HashFile(HashType)(in char* path) if (isDigest!HashType)
{
    HashType hash; 
	hash.start();

    File file = File(fromStringz(path), "rb");

    if (!file.isOpen)
        return null;

    foreach (ubyte[] buffer; file.byChunk(4 * 1024))
        hash.put(buffer);

    file.close();

    return hash.finish().dup;
}

alias char md5string[32 + 1];
export extern (C) void GetMd5OfFile(const char* fileName, md5string* md5)
{
	try
	{
		memcpy(cast(void*)md5, toStringz(toHexString(HashFile!MD5(fileName))), md5string.sizeof);
	}
	catch(Exception ex)
	{
		throw new Exception(format("Error: %s", ex.msg));
	}
}

export extern (C) void GetMd5List(char** fileList, int fileCount, md5string* md5List, uint maxThreads)
{
	try
	{
		if(maxThreads == 0)
			maxThreads = totalCPUs;

		auto pool = new TaskPool(maxThreads);

		foreach(int i; pool.parallel(iota(0,fileCount-1)))
			GetMd5OfFile(fileList[i], &md5List[i]);

		pool.finish(true);
	}
	catch(Exception ex)
	{
		log("Error: %s", ex.msg);
	}
}
