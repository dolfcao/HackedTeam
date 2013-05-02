#include <Windows.h>
#include <WinInet.h>
#include <winternl.h>
#ifndef __winapi_h
#define __winapi_h

#define CONTAINING_RECORD(address, type, field) ((type *)( (PCHAR)(address) - (ULONG_PTR)(&((type *)0)->field)))

typedef struct _FILE_NAME_INFORMATION {
  ULONG FileNameLength;
  WCHAR FileName[1];
} FILE_NAME_INFORMATION, *PFILE_NAME_INFORMATION;

// WINAPI
typedef HMODULE (WINAPI *LOADLIBRARYA)(__in LPSTR lpFileName);
typedef LOADLIBRARYA *PLOADLIBRARYA;
typedef HMODULE (WINAPI *LOADLIBRARYW)(__in LPWSTR lpFileName);
typedef LOADLIBRARYW *PLOADLIBRARYW;
typedef HMODULE (WINAPI *GETPROCADDRESS)(__in HMODULE hModule, __in LPSTR lpProcName);
typedef GETPROCADDRESS *PGETPROCADDRESS;
typedef INT (WINAPI *MESSAGEBOXA)(__in HWND hWnd, __in LPSTR lpText, __in LPSTR lpCaption, __in UINT uType);
typedef MESSAGEBOXA *PMESSAGEBOXA;

typedef VOID (WINAPI *OUTPUTDEBUGSTRINGA)(__in LPSTR lpOutputString);
typedef DWORD (WINAPI *GETFILESIZE)(__in HANDLE hFile, __out LPDWORD lpFileSizeHigh);
typedef LPVOID (WINAPI *VIRTUALALLOC)(__in LPVOID lpAddress, __in SIZE_T dwSize, __in DWORD flAllocationType, __in DWORD flProtect);
typedef BOOL (WINAPI *CLOSEHANDLE)(__in HANDLE hObject);
typedef VOID (WINAPI *SLEEP)(__in DWORD dwSec);
typedef VOID (WINAPI *EXITPROCESS)(__in DWORD uExitReason);
typedef HINSTANCE (WINAPI *SHELLEXECUTEW)(__in HWND hwnd, __in LPWSTR lpOperation, __in LPWSTR lpFile, __in LPWSTR lpParameters, __in LPWSTR lpDirectory, __in INT nShowCmd);
typedef DWORD (WINAPI *GETSHORTPATHNAMEW)(__in LPWSTR lpszLongPath, __in LPWSTR lpszShortPath, __in DWORD cchBuffer);
typedef DWORD (WINAPI *GETMODULEFILENAMEW)(__in HMODULE hModule, __out LPWSTR lpFilename, __in DWORD nSize);
typedef NTSTATUS (WINAPI *NTQUERYOBJECT)(__in HANDLE Handle, __in OBJECT_INFORMATION_CLASS ObjectInformationClass, __in PVOID ObjectInformation, __in ULONG ObjectInformationLength, __out PULONG ReturnLength);
typedef NTSTATUS (WINAPI *NTQUERYINFORMATIONFILE)(__in HANDLE FileHandle, __out PIO_STATUS_BLOCK IoStatusBlock, __out PVOID FileInformation, __in ULONG Length, __in FILE_INFORMATION_CLASS FileInformationClass);
typedef HANDLE (WINAPI *FINDFIRSTURLCACHEENTRYA)(__in LPSTR lpszUrlSearchPattern, __out LPINTERNET_CACHE_ENTRY_INFO lpFirstCacheEntryInfo, __in LPDWORD lpcbCacheEntryInfo);
typedef BOOL (WINAPI *FINDNEXTURLCACHEENTRYA)(__in HANDLE hEnumHandle, __out LPINTERNET_CACHE_ENTRY_INFO lpNextCacheEntryInfo, __in LPDWORD lpcbCacheEntryInfo);
typedef BOOL (WINAPI *DELETEURLCACHEENTRYA)(__in LPSTR lpszUrlName);
typedef BOOL (WINAPI *FINDCLOSEURLCACHE)(__in HANDLE hEnumHandle);
typedef HRESULT (WINAPI *URLDOWNLOADTOFILEA)(__in LPUNKNOWN pCaller, __in LPSTR szURL, __in LPSTR szFileName, __in DWORD dwReserved, __in LPBINDSTATUSCALLBACK lpfnCB);
typedef BOOL (WINAPI *SHGETSPECIALFOLDERPATHA)(__in HWND hwndOwner, __out LPTSTR lpszPath, __in int csidl, __in BOOL fCreate);
typedef DWORD (WINAPI *GETSHORTPATHNAMEA)(__in LPSTR lpszLongPath, __out LPTSTR lpszShortPath, __in DWORD cchBuffer);


#endif // __winapi_h