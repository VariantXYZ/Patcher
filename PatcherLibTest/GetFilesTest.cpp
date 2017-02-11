#include <stdio.h>
#include "stdafx.h"
#include "CppUnitTest.h"
#include "..\PatcherLib\PatcherLib.h"
#include <Windows.h>

#if defined(_MSC_VER) && _MSC_VER >= 1900
// MSVC 2015 inlines printf() and scanf() functions.
// As a result, MSVCRT no longer has definitions for them, resulting
// in a linker error because d3dx8.lib depends on sprintf().
// Link in legacy_stdio_definitions.lib to fix this.
// Reference: https://msdn.microsoft.com/en-us/library/Bb531344.aspx
#pragma comment(lib, "legacy_stdio_definitions.lib")
#endif

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace PatcherTest
{
	TEST_CLASS(TestGetFiles)
	{
	public:
		//TODO: Better test
		TEST_METHOD(GetFileMD5WithSubDirectories)
		{

			if ((CreateDirectory(TEXT("./TestDirectory"), NULL) ||
				ERROR_ALREADY_EXISTS == GetLastError())
				&&
				(CreateDirectory(TEXT("./TestDirectory/TestSubDirectory"), NULL) ||
					ERROR_ALREADY_EXISTS == GetLastError())
				)
			{
				FILE *fp = NULL;

				fp = fopen("./TestDirectory/a.txt", "w");
				fputs("test", fp);
				fclose(fp);
				fp = fopen("./TestDirectory/b.txt", "w");
				fclose(fp);
				fp = fopen("./TestDirectory/TestSubDirectory/c.txt", "w");
				fclose(fp);
				fp = fopen("./TestDirectory/TestSubDirectory/d.txt", "w");
				fclose(fp);

				Assert::IsTrue(GetFileCount("./TestDirectory") == 4);
				Assert::IsTrue(GetFileCount("./TestDirectory/TestSubDirectory") == 2);

				int fileListLengths[4];
				char* fileList[4];
				GetFileList("./TestDirectory", 4, fileListLengths, NULL);
				for (int i = 0; i < 4; i++)
					fileList[i] = (char*)malloc(fileListLengths[i]);
				GetFileList("./TestDirectory", 4, fileListLengths, fileList);

				md5string md5Strings[4];
				GetMd5List(fileList, 4, md5Strings, 0);

				RemoveDirectory(TEXT("./TestDirectory"));
			}
			else
			{
				Assert::Fail(TEXT("Failed to create test directory"));
			}
		}

		TEST_METHOD(TestPSO2Directory)
		{
			const char* dir = "C:\\Program Files (x86)\\SEGA\\PHANTASYSTARONLINE2\\pso2_bin\\data";
			int count = GetFileCount(dir);
			int* fileListLengths = (int*)malloc(sizeof(int)*count);
			char** fileList;
			GetFileList(dir, count, fileListLengths, NULL);
			fileList = (char**)malloc(sizeof(char*)*count);
			for (int i = 0; i < count; i++)
				fileList[i] = (char*)malloc(fileListLengths[i]);
			GetFileList(dir, count, fileListLengths, fileList);
			md5string* md5Strings = (md5string*)malloc(sizeof(md5string)*count);
			GetMd5List(fileList, count, md5Strings, 0);

			free(md5Strings);
			for (int i = 0; i < count; i++)
				free(fileList[i]);
			free(fileList);
			free(fileListLengths);
		}

	};
}