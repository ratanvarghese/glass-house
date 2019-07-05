--[[
LuaSrcDiet License
------------------

LuaSrcDiet is licensed under the terms of the MIT license reproduced
below. This means that LuaSrcDiet is free software and can be used for
both academic and commercial purposes at absolutely no cost.

Think of LuaSrcDiet as a compiler or a text filter; whatever that is
processed by LuaSrcDiet is not affected by its license. It does not add
anything new into your source code; it only transforms code that already
exist.

Hence, there is no need to tag this license onto Lua programs that are
only processed. Given the liberal terms of this kind of license, the
primary purpose is just to claim authorship of LuaSrcDiet.

Parts of LuaSrcDiet is based on Lua 5 code. See the file COPYRIGHT_Lua51
(Lua 5.1.4) for Lua 5's license.

===============================================================================

Copyright 2005-2008, 2011-2012 Kein-Hong Man <keinhong@gmail.com>.
Copyright 2017 Jakub Jirutka <jakub@jirutka.cz>.
Lua 5.1.4 Copyright 1994-2008 Lua.org, PUC-Rio.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

===============================================================================

(end of COPYRIGHT)
--]]
package.preload["luasrcdiet.equiv"]=(function(...)
local v=string.byte
local p=string.dump
local y=loadstring or load
local w=string.sub
local u={}
local i={
TK_KEYWORD=true,
TK_NAME=true,
TK_NUMBER=true,
TK_STRING=true,
TK_LSTRING=true,
TK_OP=true,
TK_EOS=true,
}
local n,e,s
function u.init(o,t,a)
n=o
e=t
s=a
end
local function o(t)
local o,n=e.lex(t)
local t,e
={},{}
for a=1,#o do
local o=o[a]
if i[o]then
t[#t+1]=o
e[#e+1]=n[a]
end
end
return t,e
end
function u.source(r,t)
local function h(e)
local e=y("return "..e,"z")
if e then
return p(e)
end
end
local function a(e)
if n.DETAILS then print("SRCEQUIV: "..e)end
s.SRC_EQUIV=true
end
local e,l=o(r)
local i,d=o(t)
local o=r:match("^(#[^\r\n]*)")
local t=t:match("^(#[^\r\n]*)")
if o or t then
if not o or not t or o~=t then
a("shbang lines different")
end
end
if#e~=#i then
a("count "..#e.." "..#i)
return
end
for t=1,#e do
local e,s=e[t],i[t]
local i,o=l[t],d[t]
if e~=s then
a("type ["..t.."] "..e.." "..s)
break
end
if e=="TK_KEYWORD"or e=="TK_NAME"or e=="TK_OP"then
if e=="TK_NAME"and n["opt-locals"]then
elseif i~=o then
a("seminfo ["..t.."] "..e.." "..i.." "..o)
break
end
elseif e=="TK_EOS"then
else
local n,s=h(i),h(o)
if not n or not s or n~=s then
a("seminfo ["..t.."] "..e.." "..i.." "..o)
break
end
end
end
end
function u.binary(A,O)
local e=0
local T=1
local j=3
local q=4
local k
local r
local l
local m
local u
local o
local c
local function e(e)
if n.DETAILS then print("BINEQUIV: "..e)end
s.BIN_EQUIV=true
end
local function n(e,t)
if e.i+t-1>e.len then return end
return true
end
local function f(t,e)
if not e then e=1 end
t.i=t.i+e
end
local function i(e)
local t=e.i
if t>e.len then return end
local a=w(e.dat,t,t)
e.i=t+1
return v(a)
end
local function x(a)
local t,e=0,1
if not n(a,r)then return end
for o=1,r do
t=t+e*i(a)
e=e*256
end
return t
end
local function _(t)
local e=0
if not n(t,r)then return end
for a=1,r do
e=e*256+i(t)
end
return e
end
local function z(a)
local t,e=0,1
if not n(a,l)then return end
for o=1,l do
t=t+e*i(a)
e=e*256
end
return t
end
local function E(t)
local e=0
if not n(t,l)then return end
for a=1,l do
e=e*256+i(t)
end
return e
end
local function h(e,o)
local t=e.i
local a=t+o-1
if a>e.len then return end
local a=w(e.dat,t,a)
e.i=t+o
return a
end
local function s(t)
local e=c(t)
if not e then return end
if e==0 then return""end
return h(t,e)
end
local function g(e,t)
local e,t=i(e),i(t)
if not e or not t or e~=t then
return
end
return e
end
local function d(e,t)
local e=g(e,t)
if not e then return true end
end
local function v(t,e)
local e,t=o(t),o(e)
if not e or not t or e~=t then
return
end
return e
end
local function b(t,a)
if not s(t)or not s(a)then
e("bad source name");return
end
if not o(t)or not o(a)then
e("bad linedefined");return
end
if not o(t)or not o(a)then
e("bad lastlinedefined");return
end
if not(n(t,4)and n(a,4))then
e("prototype header broken")
end
if d(t,a)then
e("bad nups");return
end
if d(t,a)then
e("bad numparams");return
end
if d(t,a)then
e("bad is_vararg");return
end
if d(t,a)then
e("bad maxstacksize");return
end
local i=v(t,a)
if not i then
e("bad ncode");return
end
local n=h(t,i*m)
local i=h(a,i*m)
if not n or not i or n~=i then
e("bad code block");return
end
local i=v(t,a)
if not i then
e("bad nconst");return
end
for o=1,i do
local o=g(t,a)
if not o then
e("bad const type");return
end
if o==T then
if d(t,a)then
e("bad boolean value");return
end
elseif o==j then
local t=h(t,u)
local a=h(a,u)
if not t or not a or t~=a then
e("bad number value");return
end
elseif o==q then
local t=s(t)
local a=s(a)
if not t or not a or t~=a then
e("bad string value");return
end
end
end
local i=v(t,a)
if not i then
e("bad nproto");return
end
for o=1,i do
if not b(t,a)then
e("bad function prototype");return
end
end
local n=o(t)
if not n then
e("bad sizelineinfo1");return
end
local i=o(a)
if not i then
e("bad sizelineinfo2");return
end
if not h(t,n*r)then
e("bad lineinfo1");return
end
if not h(a,i*r)then
e("bad lineinfo2");return
end
local i=o(t)
if not i then
e("bad sizelocvars1");return
end
local n=o(a)
if not n then
e("bad sizelocvars2");return
end
for a=1,i do
if not s(t)or not o(t)or not o(t)then
e("bad locvars1");return
end
end
for t=1,n do
if not s(a)or not o(a)or not o(a)then
e("bad locvars2");return
end
end
local i=o(t)
if not i then
e("bad sizeupvalues1");return
end
local o=o(a)
if not o then
e("bad sizeupvalues2");return
end
for a=1,i do
if not s(t)then e("bad upvalues1");return end
end
for t=1,o do
if not s(a)then e("bad upvalues2");return end
end
return true
end
local function t(e)
local t=e:match("^(#[^\r\n]*\r?\n?)")
if t then
e=w(e,#t+1)
end
return e
end
local s=y(t(A),"z")
if not s then
e("failed to compile original sources for binary chunk comparison")
return
end
local a=y(t(O),"z")
if not a then
e("failed to compile compressed result for binary chunk comparison")
end
local t={i=1,dat=p(s)}
t.len=#t.dat
local a={i=1,dat=p(a)}
a.len=#a.dat
if not(n(t,12)and n(a,12))then
e("header broken")
end
f(t,6)
k=i(t)
r=i(t)
l=i(t)
m=i(t)
u=i(t)
f(t)
f(a,12)
if k==1 then
o=x
c=z
else
o=_
c=E
end
b(t,a)
if t.i~=t.len+1 then
e("inconsistent binary chunk1");return
elseif a.i~=a.len+1 then
e("inconsistent binary chunk2");return
end
end
return u
end)
package.preload["luasrcdiet.fs"]=(function(...)
local a=string.format
local h=io.open
local i='\239\187\191'
local function o(t,e)
if e:sub(1,#t+2)==t..': 'then
e=e:sub(#t+3)
end
return e
end
local s={}
function s.read_file(t,e)
local n,e=h(t,e or'r')
if not n then
return nil,a('Could not open %s for reading: %s',
t,o(t,e))
end
local e,s=n:read('*a')
if not e then
return nil,a('Could not read %s: %s',t,o(t,s))
end
n:close()
if e:sub(1,#i)==i then
e=e:sub(#i+1)
end
return e
end
function s.write_file(e,i,t)
local t,n=h(e,t or'w')
if not t then
return nil,a('Could not open %s for writing: %s',
e,o(e,n))
end
local n,i=t:write(i)
if i then
return nil,a('Could not write %s: %s',e,o(e,i))
end
t:flush()
t:close()
return true
end
return s
end)
package.preload["luasrcdiet.init"]=(function(...)
local d=require'luasrcdiet.equiv'
local l=require'luasrcdiet.llex'
local u=require'luasrcdiet.lparser'
local i=require'luasrcdiet.optlex'
local r=require'luasrcdiet.optparser'
local e=require'luasrcdiet.utils'
local m=table.concat
local o=e.merge
local c
local function s()
return
end
local function n(t)
local e={}
for a,t in pairs(t)do
e['opt-'..a]=t
end
return e
end
local e={}
e._NAME='luasrcdiet'
e._VERSION='1.0.0'
e._HOMEPAGE='https://github.com/jirutka/luasrcdiet'
e.NONE_OPTS={
binequiv=false,
comments=false,
emptylines=false,
entropy=false,
eols=false,
experimental=false,
locals=false,
numbers=false,
srcequiv=false,
strings=false,
whitespace=false,
}
e.BASIC_OPTS=o(e.NONE_OPTS,{
comments=true,
emptylines=true,
srcequiv=true,
whitespace=true,
})
e.DEFAULT_OPTS=o(e.BASIC_OPTS,{
locals=true,
numbers=true,
})
e.MAXIMUM_OPTS=o(e.DEFAULT_OPTS,{
entropy=true,
eols=true,
strings=true,
})
function e.optimize(t,a)
assert(a and type(a)=='string',
'bad argument #2: expected string, got a '..type(a))
t=t and o(e.NONE_OPTS,t)or e.DEFAULT_OPTS
local n=n(t)
local o,e,h=l.lex(a)
local u=u.parse(o,e,h)
r.print=s
r.optimize(n,o,e,u)
local r=i.warn
i.print=s
c,e=i.optimize(n,o,e,h)
local e=m(e)
if t.srcequiv and not t.experimental then
d.init(n,l,r)
d.source(a,e)
if r.SRC_EQUIV then
error('Source equivalence test failed!')
end
end
return e
end
return e
end)
package.preload["luasrcdiet.llex"]=(function(...)
local i=string.find
local p=string.format
local h=string.match
local n=string.sub
local k=tonumber
local y={}
local v={}
for e in([[
and break do else elseif end false for function goto if in
local nil not or repeat return then true until while]]):gmatch("%S+")do
v[e]=true
end
local e,
c,
a,
s,
l,
u,
w,
f
local function o(a,t)
local e=#u+1
u[e]=a
w[e]=t
f[e]=l
end
local function r(t,s)
local i=n(e,t,t)
t=t+1
local e=n(e,t,t)
if(e=="\n"or e=="\r")and(e~=i)then
t=t+1
i=i..e
end
if s then o("TK_EOL",i)end
l=l+1
a=t
return t
end
local function m()
if c and h(c,"^[=@]")then
return n(c,2)
end
return"[string]"
end
local function d(a,t)
local e=y.error or error
e(p("%s:%d: %s",m(),t or l,a))
end
local function m(t)
local i=n(e,t,t)
t=t+1
local o=#h(e,"=*",t)
t=t+o
a=t
return(n(e,t,t)==i)and o or(-o)-1
end
local function p(l,h)
local t=a+1
local o=n(e,t,t)
if o=="\r"or o=="\n"then
t=r(t)
end
while true do
local o,u,i=i(e,"([\r\n%]])",t)
if not o then
d(l and"unfinished long string"or
"unfinished long comment")
end
t=o
if i=="]"then
if m(t)==h then
s=n(e,s,a)
a=a+1
return s
end
t=a
else
s=s.."\n"
t=r(t)
end
end
end
local function b(l)
local t=a
while true do
local h,u,o=i(e,"([\n\r\\\"\'])",t)
if h then
if o=="\n"or o=="\r"then
d("unfinished string")
end
t=h
if o=="\\"then
t=t+1
o=n(e,t,t)
if o==""then break end
h=i("abfnrtv\n\r",o,1,true)
if h then
if h>7 then
t=r(t)
else
t=t+1
end
elseif i(o,"%D")then
t=t+1
else
local o,e,a=i(e,"^(%d%d?%d?)",t)
t=e+1
if a+1>256 then
d("escape sequence too large")
end
end
else
t=t+1
if o==l then
a=t
return n(e,s,t-1)
end
end
else
break
end
end
d("unfinished string")
end
local function g(n,t)
e=n
c=t
a=1
l=1
u={}
w={}
f={}
local i,n,e,t=i(e,"^(#[^\r\n]*)(\r?\n?)")
if i then
a=a+#e
o("TK_COMMENT",e)
if#t>0 then r(a,true)end
end
end
function y.lex(l,t)
g(l,t)
while true do
local t=a
while true do
local c,y,l=i(e,"^([_%a][_%w]*)",t)
if c then
a=t+#l
if v[l]then
o("TK_KEYWORD",l)
else
o("TK_NAME",l)
end
break
end
local l,y,c=i(e,"^(%.?)%d",t)
if l then
if c=="."then t=t+1 end
local u,s,r=i(e,"^%d*[%.%d]*([eE]?)",t)
t=s+1
if#r==1 then
if h(e,"^[%+%-]",t)then
t=t+1
end
end
local i,t=i(e,"^[_%w]*",t)
a=t+1
local e=n(e,l,t)
if not k(e)then
d("malformed number")
end
o("TK_NUMBER",e)
break
end
local y,c,v,l=i(e,"^((%s)[ \t\v\f]*)",t)
if y then
if l=="\n"or l=="\r"then
r(t,true)
else
a=c+1
o("TK_SPACE",v)
end
break
end
local l,r=i(e,"^::",t)
if r then
a=r+1
o("TK_OP","::")
break
end
local r=h(e,"^%p",t)
if r then
s=t
local l=i("-[\"\'.=<>~",r,1,true)
if l then
if l<=2 then
if l==1 then
local r=h(e,"^%-%-(%[?)",t)
if r then
t=t+2
local h=-1
if r=="["then
h=m(t)
end
if h>=0 then
o("TK_LCOMMENT",p(false,h))
else
a=i(e,"[\n\r]",t)or(#e+1)
o("TK_COMMENT",n(e,s,a-1))
end
break
end
else
local e=m(t)
if e>=0 then
o("TK_LSTRING",p(true,e))
elseif e==-1 then
o("TK_OP","[")
else
d("invalid long string delimiter")
end
break
end
elseif l<=5 then
if l<5 then
a=t+1
o("TK_STRING",b(r))
break
end
r=h(e,"^%.%.?%.?",t)
else
r=h(e,"^%p=?",t)
end
end
a=t+#r
o("TK_OP",r)
break
end
local e=n(e,t,t)
if e~=""then
a=t+1
o("TK_OP",e)
break
end
o("TK_EOS","")
return u,w,f
end
end
end
return y
end)
package.preload["luasrcdiet.lparser"]=(function(...)
local o=string.format
local t=string.gmatch
local g=pairs
local U={}
local q,
y,
j,
A,
s,
m,
N,
e,c,u,f,
p,
a,
M,
k,
D,
l,
w,
O,
x
local v,d,b,E,T,z
local R={}
for e in t("else elseif end until <eof>","%S+")do
R[e]=true
end
local H={}
local F={}
for e,t,a in t([[
{+ 6 6}{- 6 6}{* 7 7}{/ 7 7}{% 7 7}
{^ 10 9}{.. 5 4}
{~= 3 3}{== 3 3}
{< 3 3}{<= 3 3}{> 3 3}{>= 3 3}
{and 2 2}{or 1 1}
]],"{(%S+)%s(%d+)%s(%d+)}")do
H[e]=t+0
F[e]=a+0
end
local K={["not"]=true,["-"]=true,
["#"]=true,}
local Q=8
local function i(e,t)
local a=U.error or error
a(o("(source):%d: %s",t or u,e))
end
local function t()
N=j[s]
e,c,u,f
=q[s],y[s],j[s],A[s]
s=s+1
end
local function J()
return q[s]
end
local function h(t)
if e~="<number>"and e~="<string>"then
if e=="<name>"then e=c end
e="'"..e.."'"
end
i(t.." near "..e)
end
local function n(e)
h("'"..e.."' expected")
end
local function i(a)
if e==a then t();return true end
end
local function L(t)
if e~=t then n(t)end
end
local function o(e)
L(e);t()
end
local function C(t,e)
if not t then h(e)end
end
local function r(e,a,t)
if not i(e)then
if t==u then
n(e)
else
h("'"..e.."' expected (to close '"..a.."' at line "..t..")")
end
end
end
local function n()
L("<name>")
local e=c
p=f
t()
return e
end
local function c(o,i)
local e=a.bl
local t
if e then
t=e.locallist
else
t=a.locallist
end
local e=#l+1
l[e]={
name=o,
xref={p},
decl=p,
}
if i or o=="_ENV"then
l[e].is_special=true
end
local a=#w+1
w[a]=e
O[a]=t
end
local function _(e)
local t=#w
while e>0 do
e=e-1
local e=t-e
local a=w[e]
local t=l[a]
local o=t.name
t.act=f
w[e]=nil
local i=O[e]
O[e]=nil
local e=i[o]
if e then
t=l[e]
t.rem=-a
end
i[o]=a
end
end
local function I()
local t=a.bl
local e
if t then
e=t.locallist
else
e=a.locallist
end
for t,e in g(e)do
local e=l[e]
e.rem=f
end
end
local function f(e,t)
if e:sub(1,1)=="("then
return
end
c(e,t)
end
local function S(o,a)
local t=o.bl
local e
if t then
e=t.locallist
while e do
if e[a]then return e[a]end
t=t.prev
e=t and t.locallist
end
end
e=o.locallist
return e[a]or-1
end
local function g(t,o,e)
if t==nil then
e.k="VGLOBAL"
return"VGLOBAL"
else
local a=S(t,o)
if a>=0 then
e.k="VLOCAL"
e.id=a
return"VLOCAL"
else
if g(t.prev,o,e)=="VGLOBAL"then
return"VGLOBAL"
end
e.k="VUPVAL"
return"VUPVAL"
end
end
end
local function G(o)
local t=n()
g(a,t,o)
if o.k=="VGLOBAL"then
local e=D[t]
if not e then
e=#k+1
k[e]={
name=t,
xref={p},
}
D[t]=e
else
local e=k[e].xref
e[#e+1]=p
end
else
local e=l[o.id].xref
e[#e+1]=p
end
end
local function g(t)
local e={}
e.isbreakable=t
e.prev=a.bl
e.locallist={}
a.bl=e
end
local function p()
local e=a.bl
I()
a.bl=e.prev
end
local function B()
local e
if not a then
e=M
else
e={}
end
e.prev=a
e.bl=nil
e.locallist={}
a=e
end
local function W()
I()
a=a.prev
end
local function I(e)
t()
n()
e.k="VINDEXED"
end
local function V()
t()
d({})
o("]")
end
local function Y()
if e=="<name>"then
n()
else
V()
end
o("=")
d({})
end
local function S(e)
d(e.v)
end
local function P(a)
local n=u
local t={
v={k="VVOID"},
}
a.k="VRELOCABLE"
o("{")
repeat
if e=="}"then break end
local e=e
if e=="<name>"then
if J()~="="then
S(t)
else
Y()
end
elseif e=="["then
Y()
else
S(t)
end
until not i(",")and not i(";")
r("}","{",n)
end
local function J()
local o=0
if e~=")"then
repeat
local e=e
if e=="<name>"then
c(n())
o=o+1
elseif e=="..."then
t()
a.is_vararg=true
else
h("<name> or '...' expected")
end
until a.is_vararg or not i(",")
end
_(o)
end
local function Y(i)
local o=u
local a=e
if a=="("then
if o~=N then
h("ambiguous syntax (function call x new statement)")
end
t()
if e~=")"then
v()
end
r(")","(",o)
elseif a=="{"then
P({})
elseif a=="<string>"then
t()
else
h("function arguments expected")
return
end
i.k="VCALL"
end
local function N(a)
local e=e
if e=="("then
local e=u
t()
d(a)
r(")","(",e)
elseif e=="<name>"then
G(a)
else
h("unexpected symbol")
end
end
local function S(a)
N(a)
while true do
local e=e
if e=="."then
I(a)
elseif e=="["then
V()
elseif e==":"then
t()
n()
Y(a)
elseif e=="("or e=="<string>"or e=="{"then
Y(a)
else
return
end
end
end
local function Y(o)
local e=e
if e=="<number>"then
o.k="VKNUM"
elseif e=="<string>"then
o.k="VK"
elseif e=="nil"then
o.k="VNIL"
elseif e=="true"then
o.k="VTRUE"
elseif e=="false"then
o.k="VFALSE"
elseif e=="..."then
C(a.is_vararg==true,
"cannot use '...' outside a vararg function");
o.k="VVARARG"
elseif e=="{"then
P(o)
return
elseif e=="function"then
t()
T(false,u)
return
else
S(o)
return
end
t()
end
local function N(o,i)
local a=e
local n=K[a]
if n then
t()
N(o,Q)
else
Y(o)
end
a=e
local e=H[a]
while e and e>i do
t()
a=N({},F[a])
e=H[a]
end
return a
end
function d(e)
N(e,0)
end
local function H(e)
local e=e.v.k
C(e=="VLOCAL"or e=="VUPVAL"or e=="VGLOBAL"
or e=="VINDEXED","syntax error")
if i(",")then
local e={}
e.v={}
S(e.v)
H(e)
else
o("=")
v()
return
end
end
local function N(e)
o("do")
g(false)
_(e)
b()
p()
end
local function C(e)
f("(for index)")
f("(for limit)")
f("(for step)")
c(e)
o("=")
E()
o(",")
E()
if i(",")then
E()
else
end
N(1)
end
local function F(e)
f("(for generator)")
f("(for state)")
f("(for control)")
c(e)
local e=1
while i(",")do
c(n())
e=e+1
end
o("in")
v()
N(e)
end
local function Y(t)
local a=false
G(t)
while e=="."do
I(t)
end
if e==":"then
a=true
I(t)
end
return a
end
function E()
d({})
end
local function E()
d({})
end
local function I()
t()
E()
o("then")
b()
end
local function P()
c(n())
_(1)
T(false,u)
end
local function N()
local e=0
repeat
c(n())
e=e+1
until not i(",")
if i("=")then
v()
else
end
_(e)
end
function v()
local e={}
d(e)
while i(",")do
d(e)
end
end
function T(e,t)
B()
o("(")
if e then
f("self",true)
_(1)
end
J()
o(")")
z()
r("end","function",t)
W()
end
function b()
g(false)
z()
p()
end
local function _()
local a=m
g(true)
t()
local t=n()
local e=e
if e=="="then
C(t)
elseif e==","or e=="in"then
F(t)
else
h("'=' or 'in' expected")
end
r("end","for",a)
p()
end
local function C()
local e=m
t()
E()
g(true)
o("do")
b()
r("end","while",e)
p()
end
local function F()
local e=m
g(true)
g(false)
t()
z()
r("until","repeat",e)
E()
p()
p()
end
local function p()
local a=m
I()
while e=="elseif"do
I()
end
if e=="else"then
t()
b()
end
r("end","if",a)
end
local function d()
t()
local e=e
if R[e]or e==";"then
else
v()
end
end
local function c()
local e=a.bl
t()
while e and not e.isbreakable do
e=e.prev
end
if not e then
h("no loop to break")
end
end
local function h()
t()
n()
o("::")
end
local function f()
t()
n()
end
local function o()
local t=s-1
local e={v={}}
S(e.v)
if e.v.k=="VCALL"then
x[t]="call"
else
e.prev=nil
H(e)
x[t]="assign"
end
end
local function n()
local e=m
t()
local t=Y({})
T(t,e)
end
local function v()
local e=m
t()
b()
r("end","do",e)
end
local function r()
t()
if i("function")then
P()
else
N()
end
end
local n={
["if"]=p,
["while"]=C,
["do"]=v,
["for"]=_,
["repeat"]=F,
["function"]=n,
["local"]=r,
["return"]=d,
["break"]=c,
["goto"]=f,
["::"]=h,
}
local function h()
m=u
local e=e
local t=n[e]
if t then
x[s-1]=e
t()
if e=="return"then return true end
else
o()
end
return false
end
function z()
local t=false
while not t and not R[e]do
t=h()
i(";")
end
end
local function n(e,i,n)
s=1
M={}
local t=1
q,y,j,A={},{},{},{}
for a=1,#e do
local e=e[a]
local o=true
if e=="TK_KEYWORD"or e=="TK_OP"then
e=i[a]
elseif e=="TK_NAME"then
e="<name>"
y[t]=i[a]
elseif e=="TK_NUMBER"then
e="<number>"
y[t]=0
elseif e=="TK_STRING"or e=="TK_LSTRING"then
e="<string>"
y[t]=""
elseif e=="TK_EOS"then
e="<eof>"
else
o=false
end
if o then
q[t]=e
j[t]=n[a]
A[t]=a
t=t+1
end
end
k,D,l={},{},{}
w,O={},{}
x={}
end
function U.parse(i,o,e)
n(i,o,e)
B()
a.is_vararg=true
t()
z()
L("<eof>")
W()
return{
globalinfo=k,
localinfo=l,
statinfo=x,
toklist=q,
seminfolist=y,
toklnlist=j,
xreflist=A,
}
end
return U
end)
package.preload["luasrcdiet.optlex"]=(function(...)
local b=string.char
local l=string.find
local o=string.match
local c=string.rep
local e=string.sub
local d=tonumber
local r=tostring
local w
local f={}
f.error=error
f.warn={}
local n,i,m
local q={
TK_KEYWORD=true,
TK_NAME=true,
TK_NUMBER=true,
TK_STRING=true,
TK_LSTRING=true,
TK_OP=true,
TK_EOS=true,
}
local j={
TK_COMMENT=true,
TK_LCOMMENT=true,
TK_EOL=true,
TK_SPACE=true,
}
local h
local function x(e)
local t=n[e-1]
if e<=1 or t=="TK_EOL"then
return true
elseif t==""then
return x(e-1)
end
return false
end
local function z(t)
local e=n[t+1]
if t>=#n or e=="TK_EOL"or e=="TK_EOS"then
return true
elseif e==""then
return z(t+1)
end
return false
end
local function _(a)
local t=#o(a,"^%-%-%[=*%[")
local a=e(a,t+1,-(t-1))
local e,t=1,0
while true do
local o,n,i,a=l(a,"([\r\n])([\r\n]?)",e)
if not o then break end
e=o+1
t=t+1
if#a>0 and i~=a then
e=e+1
end
end
return t
end
local function v(s,a)
local t,e=n[s],n[a]
if t=="TK_STRING"or t=="TK_LSTRING"or
e=="TK_STRING"or e=="TK_LSTRING"then
return""
elseif t=="TK_OP"or e=="TK_OP"then
if(t=="TK_OP"and(e=="TK_KEYWORD"or e=="TK_NAME"))or
(e=="TK_OP"and(t=="TK_KEYWORD"or t=="TK_NAME"))then
return""
end
if t=="TK_OP"and e=="TK_OP"then
local t,e=i[s],i[a]
if(o(t,"^%.%.?$")and o(e,"^%."))or
(o(t,"^[~=<>]$")and e=="=")or
(t=="["and(e=="["or e=="="))then
return" "
end
return""
end
local t=i[s]
if e=="TK_OP"then t=i[a]end
if o(t,"^%.%.?%.?$")then
return" "
end
return""
else
return" "
end
end
local function p()
local s,o,a={},{},{}
local e=1
for t=1,#n do
local n=n[t]
if n~=""then
s[e],o[e],a[e]=n,i[t],m[t]
e=e+1
end
end
n,i,m=s,o,a
end
local function I(s)
local t=i[s]
local a=t
local n
if o(a,"^0[xX]")then
local e=r(d(a))
if#e<=#a then
a=e
else
return
end
end
if o(a,"^%d+$")then
if d(a)>0 then
n=o(a,"^0*([1-9]%d*)$")
else
n="0"
end
elseif not o(a,"[eE]")then
local a,t=o(a,"^(%d*)%.(%d*)$")
if a==""then a=0 end
if t==""then t="0"end
if d(t)==0 and a==0 then
n=".0"
else
local i=#o(t,"0*$")
if i>0 then
t=e(t,1,#t-i)
end
if d(a)>0 then
n=a.."."..t
else
n="."..t
local a=#o(t,"^0*")
local a=#t-a
local o=r(#t)
if a+2+#o<1+#t then
n=e(t,-a).."e-"..o
end
end
end
else
local t,a=o(a,"^([^eE]+)[eE]([%+%-]?%d+)$")
a=d(a)
local i,s=o(t,"^(%d*)%.(%d*)$")
if i then
a=a-#s
t=i..s
end
if d(t)==0 then
n=".0"
else
local i=#o(t,"^0*")
t=e(t,i+1)
i=#o(t,"0*$")
if i>0 then
t=e(t,1,#t-i)
a=a+i
end
local o=r(a)
if a>=0 and(a<=1+#o)then
n=t..c("0",a).."."
elseif a<0 and(a>=-#t)then
i=#t+a
n=e(t,1,i).."."..e(t,i+1)
elseif a<0 and(#o>=-a-#t)then
i=-a-#t
n="."..c("0",i)..t
else
n=t.."e"..a
end
end
end
if n and n~=i[s]then
if h then
w("<number> (line "..m[s]..") "..i[s].." -> "..n)
h=h+1
end
i[s]=n
end
end
local function N(c)
local t=i[c]
local u=e(t,1,1)
local y=(u=="'")and'"'or"'"
local t=e(t,2,-2)
local a=1
local f,r=0,0
while a<=#t do
local c=e(t,a,a)
if c=="\\"then
local i=a+1
local n=e(t,i,i)
local s=l("abfnrtv\\\n\r\"\'0123456789",n,1,true)
if not s then
t=e(t,1,a-1)..e(t,i)
a=a+1
elseif s<=8 then
a=a+2
elseif s<=10 then
local o=e(t,i,i+1)
if o=="\r\n"or o=="\n\r"then
t=e(t,1,a).."\n"..e(t,i+2)
elseif s==10 then
t=e(t,1,a).."\n"..e(t,i+1)
end
a=a+2
elseif s<=12 then
if n==u then
f=f+1
a=a+2
else
r=r+1
t=e(t,1,a-1)..e(t,i)
a=a+1
end
else
local n=o(t,"^(%d%d?%d?)",i)
i=a+1+#n
local d=d(n)
local h=b(d)
s=l("\a\b\f\n\r\t\v",h,1,true)
if s then
n="\\"..e("abfnrtv",s,s)
elseif d<32 then
if o(e(t,i,i),"%d")then
n="\\"..n
else
n="\\"..d
end
elseif h==u then
n="\\"..h
f=f+1
elseif h=="\\"then
n="\\\\"
else
n=h
if h==y then
r=r+1
end
end
t=e(t,1,a-1)..n..e(t,i)
a=a+#n
end
else
a=a+1
if c==y then
r=r+1
end
end
end
if f>r then
a=1
while a<=#t do
local o,n,i=l(t,"([\'\"])",a)
if not o then break end
if i==u then
t=e(t,1,o-2)..e(t,o)
a=o
else
t=e(t,1,o-1).."\\"..e(t,o)
a=o+2
end
end
u=y
end
t=u..t..u
if t~=i[c]then
if h then
w("<string> (line "..m[c]..") "..i[c].." -> "..t)
h=h+1
end
i[c]=t
end
end
local function S(h)
local t=i[h]
local s=o(t,"^%[=*%[")
local a=#s
local d=e(t,-a,-1)
local r=e(t,a+1,-(a+1))
local n=""
local t=1
while true do
local a,i,d,s=l(r,"([\r\n])([\r\n]?)",t)
local i
if not a then
i=e(r,t)
elseif a>=t then
i=e(r,t,a-1)
end
if i~=""then
if o(i,"%s+$")then
f.warn.LSTRING="trailing whitespace in long string near line "..m[h]
end
n=n..i
end
if not a then
break
end
t=a+1
if a then
if#s>0 and d~=s then
t=t+1
end
if not(t==1 and t==a)then
n=n.."\n"
end
end
end
if a>=3 then
local e,t=a-1
while e>=2 do
local a="%]"..c("=",e-2).."%]"
if not o(n.."]",a)then t=e end
e=e-1
end
if t then
a=c("=",t-2)
s,d="["..a.."[","]"..a.."]"
end
end
i[h]=s..n..d
end
local function g(d)
local a=i[d]
local s=o(a,"^%-%-%[=*%[")
local t=#s
local r=e(a,-(t-2),-1)
local h=e(a,t+1,-(t-1))
local n=""
local a=1
while true do
local i,t,r,s=l(h,"([\r\n])([\r\n]?)",a)
local t
if not i then
t=e(h,a)
elseif i>=a then
t=e(h,a,i-1)
end
if t~=""then
local a=o(t,"%s*$")
if#a>0 then t=e(t,1,-(a+1))end
n=n..t
end
if not i then
break
end
a=i+1
if i then
if#s>0 and r~=s then
a=a+1
end
n=n.."\n"
end
end
t=t-2
if t>=3 then
local e,a=t-1
while e>=2 do
local t="%]"..c("=",e-2).."%]"
if not o(n,t)then a=e end
e=e-1
end
if a then
t=c("=",a-2)
s,r="--["..t.."[","]"..t.."]"
end
end
i[d]=s..n..r
end
local function k(n)
local t=i[n]
local a=o(t,"%s*$")
if#a>0 then
t=e(t,1,-(a+1))
end
i[n]=t
end
local function E(t,a)
if not t then return false end
local o=o(a,"^%-%-%[=*%[")
local o=#o
local e=e(a,o+1,-(o-1))
if l(e,t,1,true)then
return true
end
end
function f.optimize(t,s,a,o)
local u=t["opt-comments"]
local d=t["opt-whitespace"]
local l=t["opt-emptylines"]
local b=t["opt-eols"]
local T=t["opt-strings"]
local O=t["opt-numbers"]
local y=t["opt-experimental"]
local A=t.KEEP
h=t.DETAILS and 0
w=f.print or _G.print
if b then
u=true
d=true
l=true
elseif y then
d=true
end
n,i,m
=s,a,o
local t=1
local a,r
local s
local function o(o,a,e)
e=e or t
n[e]=o or""
i[e]=a or""
end
if y then
while true do
a,r=n[t],i[t]
if a=="TK_EOS"then
break
elseif a=="TK_OP"and r==";"then
o("TK_SPACE"," ")
end
t=t+1
end
p()
end
t=1
while true do
a,r=n[t],i[t]
local h=x(t)
if h then s=nil end
if a=="TK_EOS"then
break
elseif a=="TK_KEYWORD"or
a=="TK_NAME"or
a=="TK_OP"then
s=t
elseif a=="TK_NUMBER"then
if O then
I(t)
end
s=t
elseif a=="TK_STRING"or
a=="TK_LSTRING"then
if T then
if a=="TK_STRING"then
N(t)
else
S(t)
end
end
s=t
elseif a=="TK_COMMENT"then
if u then
if t==1 and e(r,1,1)=="#"then
k(t)
else
o()
end
elseif d then
k(t)
end
elseif a=="TK_LCOMMENT"then
if E(A,r)then
if d then
g(t)
end
s=t
elseif u then
local e=_(r)
if j[n[t+1]]then
o()
a=""
else
o("TK_SPACE"," ")
end
if not l and e>0 then
o("TK_EOL",c("\n",e))
end
if d and a~=""then
t=t-1
end
else
if d then
g(t)
end
s=t
end
elseif a=="TK_EOL"then
if h and l then
o()
elseif r=="\r\n"or r=="\n\r"then
o("TK_EOL","\n")
end
elseif a=="TK_SPACE"then
if d then
if h or z(t)then
o()
else
local a=n[s]
if a=="TK_LCOMMENT"then
o()
else
local e=n[t+1]
if j[e]then
if(e=="TK_COMMENT"or e=="TK_LCOMMENT")and
a=="TK_OP"and i[s]=="-"then
else
o()
end
else
local e=v(s,t+1)
if e==""then
o()
else
o("TK_SPACE"," ")
end
end
end
end
end
else
error("unidentified token encountered")
end
t=t+1
end
p()
if b then
t=1
if n[1]=="TK_COMMENT"then
t=3
end
while true do
a=n[t]
if a=="TK_EOS"then
break
elseif a=="TK_EOL"then
local a,e=n[t-1],n[t+1]
if q[a]and q[e]then
local t=v(t-1,t+1)
if t==""or e=="TK_EOS"then
o()
end
end
end
t=t+1
end
p()
end
if h and h>0 then w()end
return n,i,m
end
return f
end)
package.preload["luasrcdiet.optparser"]=(function(...)
local d=string.byte
local f=string.char
local c=table.concat
local t=string.format
local b=pairs
local j=string.rep
local x=table.sort
local r=string.sub
local z={}
local o="etaoinshrdlucmfwypvbgkqjxz_ETAOINSHRDLUCMFWYPVBGKQJXZ"
local s="etaoinshrdlucmfwypvbgkqjxz_0123456789ETAOINSHRDLUCMFWYPVBGKQJXZ"
local _={}
for e in([[
and break do else elseif end false for function if in
local nil not or repeat return then true until while
self _ENV]]):gmatch("%S+")do
_[e]=true
end
local n,l,
i,g,m,
q,a,
u,
v,E,
p,
h
local function k(e)
local i={}
for n=1,#e do
local e=e[n]
local o=e.name
if not i[o]then
i[o]={
decl=0,token=0,size=0,
}
end
local t=i[o]
t.decl=t.decl+1
local i=e.xref
local a=#i
t.token=t.token+a
t.size=t.size+a*#o
if e.decl then
e.id=n
e.xcount=a
if a>1 then
e.first=i[2]
e.last=i[a]
end
else
t.id=n
end
end
return i
end
local function N(e)
local i={
TK_KEYWORD=true,TK_NAME=true,TK_NUMBER=true,
TK_STRING=true,TK_LSTRING=true,
}
if not e["opt-comments"]then
i.TK_COMMENT=true
i.TK_LCOMMENT=true
end
local e={}
for t=1,#n do
e[t]=l[t]
end
for t=1,#a do
local t=a[t]
local a=t.xref
for t=1,t.xcount do
local t=a[t]
e[t]=""
end
end
local t={}
for e=0,255 do t[e]=0 end
for a=1,#n do
local a,e=n[a],e[a]
if i[a]then
for a=1,#e do
local e=d(e,a)
t[e]=t[e]+1
end
end
end
local function i(a)
local e={}
for o=1,#a do
local a=d(a,o)
e[o]={c=a,freq=t[a],}
end
x(e,function(e,t)
return e.freq>t.freq
end)
local a={}
for t=1,#e do
a[t]=f(e[t].c)
end
return c(a)
end
o=i(o)
s=i(s)
end
local function I()
local t
local n,h=#o,#s
local e=p
if e<n then
e=e+1
t=r(o,e,e)
else
local i,a=n,1
repeat
e=e-i
i=i*h
a=a+1
until i>e
local i=e%n
e=(e-i)/n
i=i+1
t=r(o,i,i)
while a>1 do
local o=e%h
e=(e-o)/h
o=o+1
t=t..r(s,o,o)
a=a-1
end
end
p=p+1
return t,v[t]~=nil
end
local function T(g,k,v,o)
local e=z.print or print
local u=o.DETAILS
if o.QUIET then return end
local c,f,w=0,0,0
local p,y,m=0,0,0
local n,l,d=0,0,0
local i,s,r=0,0,0
local function o(e,t)
if e==0 then return 0 end
return t/e
end
for t,e in b(g)do
c=c+1
n=n+e.token
i=i+e.size
end
for t,e in b(k)do
f=f+1
y=y+e.decl
l=l+e.token
s=s+e.size
end
for t,e in b(v)do
w=w+1
m=m+e.decl
d=d+e.token
r=r+e.size
end
local E=c+f
local T=p+y
local z=n+l
local q=i+s
local O=c+w
local A=p+m
local k=n+d
local _=i+r
if u then
local u={}
for t,e in b(g)do
e.name=t
u[#u+1]=e
end
x(u,function(t,e)
return t.size>e.size
end)
do
local a,h="%8s%8s%10s  %s","%8d%8d%10.2f  %s"
local s=j("-",44)
e("*** global variable list (sorted by size) ***\n"..s)
e(t(a,"Token","Input","Input","Global"))
e(t(a,"Count","Bytes","Average","Name"))
e(s)
for a=1,#u do
local a=u[a]
e(t(h,a.token,a.size,o(a.token,a.size),a.name))
end
e(s)
e(t(h,n,i,o(n,i),"TOTAL"))
e(s.."\n")
end
do
local i,u="%8s%8s%8s%10s%8s%10s  %s","%8d%8d%8d%10.2f%8d%10.2f  %s"
local n=j("-",70)
e("*** local variable list (sorted by allocation order) ***\n"..n)
e(t(i,"Decl.","Token","Input","Input","Output","Output","Global"))
e(t(i,"Count","Count","Bytes","Average","Bytes","Average","Name"))
e(n)
for i=1,#h do
local h=h[i]
local i=v[h]
local s,n=0,0
for t=1,#a do
local e=a[t]
if e.name==h then
s=s+e.xcount
n=n+e.xcount*#e.oldname
end
end
e(t(u,i.decl,i.token,n,o(s,n),
i.size,o(i.token,i.size),h))
end
e(n)
e(t(u,m,d,s,o(l,s),
r,o(d,r),"TOTAL"))
e(n.."\n")
end
end
do
local u,h="%-16s%8s%8s%8s%8s%10s","%-16s%8d%8d%8d%8d%10.2f"
local a=j("-",58)
e("*** local variable optimization summary ***\n"..a)
e(t(u,"Variable","Unique","Decl.","Token","Size","Average"))
e(t(u,"Types","Names","Count","Count","Bytes","Bytes"))
e(a)
e(t(h,"Global",c,p,n,i,o(n,i)))
e(a)
e(t(h,"Local (in)",f,y,l,s,o(l,s)))
e(t(h,"TOTAL (in)",E,T,z,q,o(z,q)))
e(a)
e(t(h,"Local (out)",w,m,d,r,o(d,r)))
e(t(h,"TOTAL (out)",O,A,k,_,o(k,_)))
e(a.."\n")
end
end
local function c()
local function o(e)
local a=i[e+1]or""
local t=i[e+2]or""
local e=i[e+3]or""
if a=="("and t=="<string>"and e==")"then
return true
end
end
local a={}
local e=1
while e<=#i do
local t=u[e]
if t=="call"and o(e)then
a[e+1]=true
a[e+3]=true
e=e+3
end
e=e+1
end
local s={}
do
local e,t,o=1,1,#i
while t<=o do
if a[e]then
s[m[e]]=true
e=e+1
end
if e>t then
if e<=o then
i[t]=i[e]
g[t]=g[e]
m[t]=m[e]-(e-t)
u[t]=u[e]
else
i[t]=nil
g[t]=nil
m[t]=nil
u[t]=nil
end
end
e=e+1
t=t+1
end
end
do
local e,t,a=1,1,#n
while t<=a do
if s[e]then
e=e+1
end
if e>t then
if e<=a then
n[t]=n[e]
l[t]=l[e]
else
n[t]=nil
l[t]=nil
end
end
e=e+1
t=t+1
end
end
end
local function f(d)
p=0
h={}
v=k(q)
E=k(a)
if d["opt-entropy"]then
N(d)
end
local e={}
for t=1,#a do
e[t]=a[t]
end
x(e,function(e,t)
return e.xcount>t.xcount
end)
local o,t,r={},1,{}
for a=1,#e do
local e=e[a]
if not e.is_special then
o[t]=e
t=t+1
else
r[#r+1]=e.name
end
end
e=o
local s=#e
while s>0 do
local n,t
repeat
n,t=I()
until not _[n]
h[#h+1]=n
local o=s
if t then
local i=q[v[n].id].xref
local n=#i
for t=1,s do
local t=e[t]
local s,e=t.act,t.rem
while e<0 do
e=a[-e].rem
end
local a
for t=1,n do
local t=i[t]
if t>=s and t<=e then a=true end
end
if a then
t.skip=true
o=o-1
end
end
end
while o>0 do
local t=1
while e[t].skip do
t=t+1
end
o=o-1
local i=e[t]
t=t+1
i.newname=n
i.skip=true
i.done=true
local s,r=i.first,i.last
local h=i.xref
if s and o>0 then
local n=o
while n>0 do
while e[t].skip do
t=t+1
end
n=n-1
local e=e[t]
t=t+1
local n,t=e.act,e.rem
while t<0 do
t=a[-t].rem
end
if not(r<n or s>t)then
if n>=i.act then
for a=1,i.xcount do
local a=h[a]
if a>=n and a<=t then
o=o-1
e.skip=true
break
end
end
else
if e.last and e.last>=i.act then
o=o-1
e.skip=true
end
end
end
if o==0 then break end
end
end
end
local a,t={},1
for o=1,s do
local e=e[o]
if not e.done then
e.skip=false
a[t]=e
t=t+1
end
end
e=a
s=#e
end
for e=1,#a do
local e=a[e]
local t=e.xref
if e.newname then
for a=1,e.xcount do
local t=t[a]
l[t]=e.newname
end
e.name,e.oldname
=e.newname,e.name
else
e.oldname=e.name
end
end
for t,e in ipairs(r)do
h[#h+1]=e
end
local e=k(a)
T(v,E,e,d)
end
function z.optimize(t,o,s,e)
n,l
=o,s
i,g,m
=e.toklist,e.seminfolist,e.xreflist
q,a,u
=e.globalinfo,e.localinfo,e.statinfo
if t["opt-locals"]then
f(t)
end
if t["opt-experimental"]then
c()
end
end
return z
end)
package.preload["luasrcdiet.utils"]=(function(...)
local a=ipairs
local o=pairs
local t={}
function t.merge(...)
local e={}
for a,t in a{...}do
for a,t in o(t)do
e[a]=t
end
end
return e
end
return t
end)
local k=require"luasrcdiet.equiv"
local c=require"luasrcdiet.fs"
local f=require"luasrcdiet.llex"
local _=require"luasrcdiet.lparser"
local e=require"luasrcdiet.init"
local q=require"luasrcdiet.optlex"
local E=require"luasrcdiet.optparser"
local d=string.byte
local U=table.concat
local b=string.find
local s=string.format
local r=string.gmatch
local T=string.match
local a=print
local v=string.rep
local u=string.sub
local o
local t=T(_VERSION," (5%.[123])$")or"5.1"
local w=t=="5.1"and not package.loaded.jit
local y=s([[
LuaSrcDiet: Puts your Lua 5.1+ source code on a diet
Version %s <%s>
]],e._VERSION,e._HOMEPAGE)
local g=[[
usage: luasrcdiet [options] [filenames]

example:
  >luasrcdiet myscript.lua -o myscript_.lua

options:
  -v, --version       prints version information
  -h, --help          prints usage information
  -o <file>           specify file name to write output
  -s <suffix>         suffix for output files (default '_')
  --keep <msg>        keep block comment with <msg> inside
  --plugin <module>   run <module> in plugin/ directory
  -                   stop handling arguments

  (optimization levels)
  --none              all optimizations off (normalizes EOLs only)
  --basic             lexer-based optimizations only
  --maximum           maximize reduction of source

  (informational)
  --quiet             process files quietly
  --read-only         read file and print token stats only
  --dump-lexer        dump raw tokens from lexer to stdout
  --dump-parser       dump variable tracking tables from parser
  --details           extra info (strings, numbers, locals)

features (to disable, insert 'no' prefix like --noopt-comments):
%s
default settings:
%s]]
local p=[[
--opt-comments,'remove comments and block comments'
--opt-whitespace,'remove whitespace excluding EOLs'
--opt-emptylines,'remove empty lines'
--opt-eols,'all above, plus remove unnecessary EOLs'
--opt-strings,'optimize strings and long strings'
--opt-numbers,'optimize numbers'
--opt-locals,'optimize local variable names'
--opt-entropy,'tries to reduce symbol entropy of locals'
--opt-srcequiv,'insist on source (lexer stream) equivalence'
--opt-binequiv,'insist on binary chunk equivalence (only for PUC Lua 5.1)'
--opt-experimental,'apply experimental optimizations'
]]
local A=[[
  --opt-comments --opt-whitespace --opt-emptylines
  --opt-numbers --opt-locals
  --opt-srcequiv --noopt-binequiv
]]
local L=[[
  --opt-comments --opt-whitespace --opt-emptylines
  --noopt-eols --noopt-strings --noopt-numbers
  --noopt-locals --noopt-entropy
  --opt-srcequiv --noopt-binequiv
]]
local D=[[
  --opt-comments --opt-whitespace --opt-emptylines
  --opt-eols --opt-strings --opt-numbers
  --opt-locals --opt-entropy
  --opt-srcequiv
]]..(w and' --opt-binequiv'or' --noopt-binequiv')
local S=[[
  --noopt-comments --noopt-whitespace --noopt-emptylines
  --noopt-eols --noopt-strings --noopt-numbers
  --noopt-locals --noopt-entropy
  --opt-srcequiv --noopt-binequiv
]]
local h="_"
local N="luasrcdiet.plugin."
local function i(e)
a("LuaSrcDiet (error): "..e);os.exit(1)
end
local n=""
do
local o=24
local a={}
for t,i in r(p,"%s*([^,]+),'([^']+)'")do
local e="  "..t
e=e..v(" ",o-#e)..i.."\n"
n=n..e
a[t]=true
a["--no"..u(t,3)]=true
end
p=a
end
g=s(g,n,A)
local O=h
local e={}
local n,h
local function m(t)
for t in r(t,"(%-%-%S+)")do
if u(t,3,4)=="no"and
p["--"..u(t,5)]then
e[u(t,5)]=false
else
e[u(t,3)]=true
end
end
end
local l={
"TK_KEYWORD","TK_NAME","TK_NUMBER",
"TK_STRING","TK_LSTRING","TK_OP",
"TK_EOS",
"TK_COMMENT","TK_LCOMMENT",
"TK_EOL","TK_SPACE",
}
local I=7
local R={
["\n"]="LF",["\r"]="CR",
["\n\r"]="LFCR",["\r\n"]="CRLF",
}
local function r(e)
local e,t=c.read_file(e,"rb")
if not e then i(t)end
return e
end
local function H(e,t)
local e,t=c.write_file(e,t,"wb")
if not e then i(t)end
end
local function x()
n,h={},{}
for e=1,#l do
local e=l[e]
n[e],h[e]=0,0
end
end
local function j(e,t)
n[e]=n[e]+1
h[e]=h[e]+#t
end
local function z()
local function i(e,t)
if e==0 then return 0 end
return t/e
end
local o={}
local e,t=0,0
for a=1,I do
local a=l[a]
e=e+n[a];t=t+h[a]
end
n.TOTAL_TOK,h.TOTAL_TOK=e,t
o.TOTAL_TOK=i(e,t)
e,t=0,0
for a=1,#l do
local a=l[a]
e=e+n[a];t=t+h[a]
o[a]=i(n[a],h[a])
end
n.TOTAL_ALL,h.TOTAL_ALL=e,t
o.TOTAL_ALL=i(e,t)
return o
end
local function I(e)
local e=r(e)
local t,o=f.lex(e)
for e=1,#t do
local t,e=t[e],o[e]
if t=="TK_OP"and d(e)<32 then
e="("..d(e)..")"
elseif t=="TK_EOL"then
e=R[e]
else
e="'"..e.."'"
end
a(t.." "..e)
end
end
local function M(e)
local e=r(e)
local t,o,e=f.lex(e)
local e=_.parse(t,o,e)
local t,i=e.globalinfo,e.localinfo
local o=v("-",72)
a("*** Local/Global Variable Tracker Tables ***")
a(o.."\n GLOBALS\n"..o)
for e=1,#t do
local t=t[e]
local e="("..e..") '"..t.name.."' -> "
local t=t.xref
for o=1,#t do e=e..t[o].." "end
a(e)
end
a(o.."\n LOCALS (decl=declared act=activated rem=removed)\n"..o)
for e=1,#i do
local t=i[e]
local e="("..e..") '"..t.name.."' decl:"..t.decl..
" act:"..t.act.." rem:"..t.rem
if t.is_special then
e=e.." is_special"
end
e=e.." -> "
local t=t.xref
for o=1,#t do e=e..t[o].." "end
a(e)
end
a(o.."\n")
end
local function C(e)
local t=r(e)
local t,o=f.lex(t)
a(y)
a("Statistics for: "..e.."\n")
x()
for e=1,#t do
local e,t=t[e],o[e]
j(e,t)
end
local o=z()
local function t(e)
return n[e],h[e],o[e]
end
local i,o="%-16s%8s%8s%10s","%-16s%8d%8d%10.2f"
local e=v("-",42)
a(s(i,"Lexical","Input","Input","Input"))
a(s(i,"Elements","Count","Bytes","Average"))
a(e)
for i=1,#l do
local i=l[i]
a(s(o,i,t(i)))
if i=="TK_EOS"then a(e)end
end
a(e)
a(s(o,"Total Elements",t("TOTAL_ALL")))
a(e)
a(s(o,"Total Tokens",t("TOTAL_TOK")))
a(e.."\n")
end
local function R(p,m)
local function t(...)
if e.QUIET then return end
_G.print(...)
end
if o and o.init then
e.EXIT=false
o.init(e,p,m)
if e.EXIT then return end
end
t(y)
local u=r(p)
if o and o.post_load then
u=o.post_load(u)or u
if e.EXIT then return end
end
local a,d,c=f.lex(u)
if o and o.post_lex then
o.post_lex(a,d,c)
if e.EXIT then return end
end
x()
for e=1,#a do
local e,t=a[e],d[e]
j(e,t)
end
local g=z()
local T,y=n,h
E.print=t
local r=_.parse(a,d,c)
if o and o.post_parse then
o.post_parse(r.globalinfo,r.localinfo)
if e.EXIT then return end
end
E.optimize(e,a,d,r)
if o and o.post_optparse then
o.post_optparse()
if e.EXIT then return end
end
local r=q.warn
q.print=t
a,d,c
=q.optimize(e,a,d,c)
if o and o.post_optlex then
o.post_optlex(a,d,c)
if e.EXIT then return end
end
local o=U(d)
if b(o,"\r\n",1,1)or
b(o,"\n\r",1,1)then
r.MIXEDEOL=true
end
k.init(e,f,r)
k.source(u,o)
if w then
k.binary(u,o)
end
local u="before and after lexer streams are NOT equivalent!"
local c="before and after binary chunks are NOT equivalent!"
if r.SRC_EQUIV then
if e["opt-srcequiv"]then i(u)end
else
t("*** SRCEQUIV: token streams are sort of equivalent")
if e["opt-locals"]then
t("(but no identifier comparisons since --opt-locals enabled)")
end
t()
end
if r.BIN_EQUIV then
if e["opt-binequiv"]then i(c)end
elseif w then
t("*** BINEQUIV: binary chunks are sort of equivalent")
t()
end
H(m,o)
x()
for e=1,#a do
local t,e=a[e],d[e]
j(t,e)
end
local a=z()
t("Statistics for: "..p.." -> "..m.."\n")
local function i(e)
return T[e],y[e],g[e],
n[e],h[e],a[e]
end
local o,a="%-16s%8s%8s%10s%8s%8s%10s",
"%-16s%8d%8d%10.2f%8d%8d%10.2f"
local e=v("-",68)
t("*** lexer-based optimizations summary ***\n"..e)
t(s(o,"Lexical",
"Input","Input","Input",
"Output","Output","Output"))
t(s(o,"Elements",
"Count","Bytes","Average",
"Count","Bytes","Average"))
t(e)
for o=1,#l do
local o=l[o]
t(s(a,o,i(o)))
if o=="TK_EOS"then t(e)end
end
t(e)
t(s(a,"Total Elements",i("TOTAL_ALL")))
t(e)
t(s(a,"Total Tokens",i("TOTAL_TOK")))
t(e)
if r.LSTRING then
t("* WARNING: "..r.LSTRING)
elseif r.MIXEDEOL then
t("* WARNING: ".."output still contains some CRLF or LFCR line endings")
elseif r.SRC_EQUIV then
t("* WARNING: "..u)
elseif r.BIN_EQUIV then
t("* WARNING: "..c)
end
t()
end
local h={...}
m(A)
local function d(n)
for t=1,#n do
local t=n[t]
local a
local o,r=b(t,"%.[^%.%\\%/]*$")
local s,h=t,""
if o and o>1 then
s=u(t,1,o-1)
h=u(t,o,r)
end
a=s..O..h
if#n==1 and e.OUTPUT_FILE then
a=e.OUTPUT_FILE
end
if t==a then
i("output filename identical to input filename")
end
if e.DUMP_LEXER then
I(t)
elseif e.DUMP_PARSER then
M(t)
elseif e.READ_ONLY then
C(t)
else
R(t,a)
end
end
end
local function r()
local s={}
local t,n=#h,1
if t==0 then
e.HELP=true
end
while n<=t do
local t,a=h[n],h[n+1]
local h=T(t,"^%-%-?")
if h=="-"then
if t=="-h"then
e.HELP=true;break
elseif t=="-v"then
e.VERSION=true;break
elseif t=="-s"then
if not a then i("-s option needs suffix specification")end
O=a
n=n+1
elseif t=="-o"then
if not a then i("-o option needs a file name")end
e.OUTPUT_FILE=a
n=n+1
elseif t=="-"then
break
else
i("unrecognized option "..t)
end
elseif h=="--"then
if t=="--help"then
e.HELP=true;break
elseif t=="--version"then
e.VERSION=true;break
elseif t=="--keep"then
if not a then i("--keep option needs a string to match for")end
e.KEEP=a
n=n+1
elseif t=="--plugin"then
if not a then i("--plugin option needs a module name")end
if e.PLUGIN then i("only one plugin can be specified")end
e.PLUGIN=a
o=require(N..a)
n=n+1
elseif t=="--quiet"then
e.QUIET=true
elseif t=="--read-only"then
e.READ_ONLY=true
elseif t=="--basic"then
m(L)
elseif t=="--maximum"then
m(D)
elseif t=="--none"then
m(S)
elseif t=="--dump-lexer"then
e.DUMP_LEXER=true
elseif t=="--dump-parser"then
e.DUMP_PARSER=true
elseif t=="--details"then
e.DETAILS=true
elseif p[t]then
m(t)
else
i("unrecognized option "..t)
end
else
s[#s+1]=t
end
n=n+1
end
if e.HELP then
a(y..g);return true
elseif e.VERSION then
a(y);return true
end
if e["opt-binequiv"]and not w then
i("--opt-binequiv is available only for PUC Lua 5.1!")
end
if#s>0 then
if#s>1 and e.OUTPUT_FILE then
i("with -o, only one source file can be specified")
end
d(s)
return true
else
i("nothing to do!")
end
end
if not r()then
i("Please run with option -h or --help for usage information")
end
