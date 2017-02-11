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
		TEST_METHOD(GetFilesWithSubDirectories)
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
			
				RemoveDirectory(TEXT("./TestDirectory"));
			}
			else
			{
				Assert::Fail(TEXT("Failed to create test directory"));
			}
		}

	};
}