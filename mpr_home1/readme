#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <algorithm>
#include <ctime>
#include <limits.h>

using namespace std;

unsigned int HashLy(const char * str)
{
    unsigned int hash = 0;
    for(; *str; str++)
        hash = (hash * 1664525) + (unsigned char)(*str) + 1013904223;
    return hash;
}
int main()

{
    srand( time( 0 ) );
    vector<int>spisok;
    int bufsize=110000;
    unsigned int max=UINT_MAX;
//for(i=0;i<INT_MAX;i++


/*int a=61;
char b='0'+char(a);
cout<<b<<endl;
for(int k=49;k<75;k++)
{
char z='0'+char(k);
cout<<z<<endl;
}*/
    for(int i=0;i<bufsize;i++)
    {
        char *str = new char[ 11 ];
        for( int i = 0; i<10; i++ )
        {
            if(i==1 ||i==5)
            { int digit=rand()%8+18;
                str[i] = '0' + char(digit);
            }
            else
            {
                int digit = rand()%9+0;
                str[i] = '0' + char(digit);
            }

        }

        str[10] = '\0';
//cout<<str<<endl;
//p=itoa(a,buf,radix);
//cout<<str<<endl;

        spisok.push_back(HashLy(str));
        delete[] str;
    }

    vector<int>::iterator new_end;
    sort(spisok.begin(),spisok.end());
    new_end=unique(spisok.begin(),spisok.end());
    vector<int>::iterator i;


    spisok.erase(spisok.begin(),new_end);
    int g=0;
    for(i=spisok.begin();i!=spisok.end();++i)
    {
        cout<<spisok[g]<<endl;
        g++;
    }
    cout<<g<<" is the number of same HASH"<<endl;
    cin.get();
    return 0;
}
