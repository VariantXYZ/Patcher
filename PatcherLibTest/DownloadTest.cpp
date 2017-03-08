#include <stdio.h>
#include "stdafx.h"
#include "CppUnitTest.h"
#include "..\PatcherLib\PatcherLib.h"
#include <Windows.h>

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace PatcherTest
{
	TEST_CLASS(TestDownload)
	{
	public:
		//TODO: Better test
		TEST_METHOD(GetFileFromServer)
		{
			DownloadFile("http://download.pso2.jp/patch_prod/patches/patchlist.txt", "C:\\patchlist.txt", "AQUA_HTTP");
		}

	};
}