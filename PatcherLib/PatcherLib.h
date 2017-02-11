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

#ifdef __cplusplus
}
#endif

#endif