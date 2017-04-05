module PatcherLib;

import core.stdc.string;
import std.algorithm;
import std.net.curl;
import std.exception;
import std.file;
import std.digest.md;
import std.parallelism;
import std.range;
import std.stdio;
import std.string;

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

    foreach (ubyte[] buffer; file.byChunk(0x8000))
        hash.put(buffer);

    file.close();

    return hash.finish().dup;
}

alias char[32 + 1] md5string;
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

export extern (C) void DownloadFile(const char* uri, const char* dest, const char* userAgent)
{
 	HTTP http = HTTP();
	http.setUserAgent(fromStringz(userAgent));
	download(fromStringz(uri), cast(string)fromStringz(dest), http);
}

export extern (C) void DownloadFiles(const char** uriList, const char** destList, int uriCount, const char* userAgent, uint maxThreads)
{
	try
	{
		if(maxThreads == 0)
			maxThreads = totalCPUs;

		auto pool = new TaskPool(maxThreads);

		foreach(int i; pool.parallel(iota(0,uriCount-1)))
			DownloadFile(uriList[i], destList[i], userAgent);

		pool.finish(true);
	}
	catch(Exception ex)
	{
		log("Error: %s", ex.msg);
	}
}