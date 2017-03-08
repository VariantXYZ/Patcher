import std.stdio;

import PatcherLib;

int main(string[] argv)
{
	DownloadFile("http://download.pso2.jp/patch_prod/patches/patchlist.txt", "C:\\patchlist.txt", "AQUA_HTTP");
    return 0;
}
