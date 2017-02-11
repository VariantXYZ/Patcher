#ifndef PATCHER_H
#define PATCHER_H

#ifdef __cplusplus
extern "C" {
#endif

	// Return number of files under directory and subdirectories
	// Will return -1 if directory could not be opened
	int GetFileCount(const char* directory);

	// If fileList is NULL, it will populate fileListLengths with the required string lengths for each file
	// Else it will populate fileList with the file names
	// Use GetFileCount to determine fileCount and allocate an int array of fileCount elements
	void GetFileList(const char* directory, int fileCount, int* fileListLengths, char** fileList);
	
	typedef char md5string[32 + 1];
	// Get MD5 of specified file
	void GetMd5OfFile(const char* fileName, md5string* md5);

	// Given a list of files, populate their 32 character MD5s in a pre-allocated array
	// Attempts to do in parallel, if maxThreads is set to 0, will use as many threads as available on the CPU
	void GetMd5List(char** fileList, int fileCount, md5string* md5List, unsigned int maxThreads);

#ifdef __cplusplus
}
#endif

#endif