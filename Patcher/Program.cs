using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;

namespace Patcher
{
    class Program
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr LoadLibrary(string libname);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        private static extern bool FreeLibrary(IntPtr hModule);

        [DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
        public static extern IntPtr GetProcAddress(IntPtr hModule, string procedureName);

        [DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
        public static extern IntPtr GetProcAddress(IntPtr hModule, int ordinal);

        private static readonly Destructor Finalize = new Destructor();

        internal static IntPtr DllHandle;

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        internal delegate int GetFileCount_t(string directory);
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        internal delegate void GetFileList_t(string directory, int fileCount, int[] fileListLengths, [In][Out] string[] fileList);
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        internal delegate void GetMd5OfFile_t(string fileName, string md5);
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        internal delegate void GetMd5List_t(string[] fileList, int fileCount, [In][Out] char[,] md5List, uint maxThreads);

        public static readonly GetFileCount_t GetFileCount;
        public static readonly GetFileList_t GetFileList;
        public static readonly GetMd5OfFile_t GetMd5OfFile;
        public static readonly GetMd5List_t GetMd5List;

        static T IntPtrToDelegate<T>(IntPtr ptr) where T : class
        {
            return (T)((object)Marshal.GetDelegateForFunctionPointer(ptr, typeof(T)));
        }

        static Program()
        {
            string dllPath = Path.Combine(Path.GetTempPath(), "PatcherLib.dll");
            File.WriteAllBytes(dllPath, Properties.Resources.PatcherLib);
            DllHandle = LoadLibrary(dllPath);

            GetFileCount = IntPtrToDelegate<GetFileCount_t>(GetProcAddress(DllHandle, "GetFileCount"));
            GetFileList = IntPtrToDelegate<GetFileList_t>(GetProcAddress(DllHandle, "GetFileList"));
            GetMd5OfFile = IntPtrToDelegate<GetMd5OfFile_t>(GetProcAddress(DllHandle, "GetMd5OfFile"));
            GetMd5List = IntPtrToDelegate<GetMd5List_t>(GetProcAddress(DllHandle, "GetMd5List"));
        }

        private sealed class Destructor
        {
            ~Destructor()
            {
                FreeLibrary(DllHandle);
            }
        }

        public static IEnumerable<T> GetRow<T>(T[,] array, int index)
        {
            for (int i = 0; i < array.GetLength(1); i++)
            {
                yield return array[index, i];
            }
        }

        static void Main(string[] args)
        {
            string dirPath = args[0];

            int fileCount = GetFileCount(dirPath);
            Console.WriteLine($"GetFileCount = {fileCount}");

            int[] fileListLengths = new int[fileCount];
            GetFileList(dirPath, fileCount, fileListLengths, null);

            string[] fileList = new string[fileCount];
            for (int i = 0; i < fileCount; i++)
                fileList[i] = new string('\0', fileListLengths[i]);

            GetFileList(dirPath, fileCount, fileListLengths, fileList);

            Stopwatch stopWatch = new Stopwatch();
            char[,] md5List = new char[fileCount, 32 + 1];
            stopWatch.Start();
            if(args.Count() > 1)
                GetMd5List(fileList, fileCount, md5List, Convert.ToUInt32(args[1]));
            else
                GetMd5List(fileList, fileCount, md5List, 0);
            stopWatch.Stop();

            for (int i = 0; i < md5List.GetLength(0); i++)
            {
                string md5 = new string(GetRow(md5List, i).ToArray());
                Console.WriteLine(String.Format($"{fileList[i]}: {md5}"));
            }

            Console.WriteLine($"MD5 of {fileCount} files took {stopWatch.Elapsed} ms");
            Console.WriteLine("Press any key...");
            Console.ReadKey();
        }
    }
}
