*! version 2.0.5  25jun2009  Ben Jann

program rdoc
    version 9.2
    gettoken subcmd 0 : 0, parse(", ")
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'==substr("init",1,max(`length',1)) {
        rdoc_init`macval(0)'
    }
    else if `"`subcmd'"'==substr("close",1,max(`length',1)) {
        rdoc_close`macval(0)'
    }
    else if `"`subcmd'"'==substr("stlog",1,max(`length',1)) {
        rdoc_stlog`macval(0)'
    }
    else if `"`subcmd'"'=="do" {
        local caller : di _caller()
        version `caller': rdoc_do`macval(0)'
    }
    else if `"`subcmd'"'=="strip" {
        rdoc_strip`macval(0)'
    }
    else {
        di as err `"`subcmd' invalid subcommand"'
        exit 198
    }
end

program rdoc_init
    syntax anything(id="document name" equalok everything) [, Replace Prefix(str asis) ]

    // check whether sjlatex is installed
    capt which sjlatex
    if _rc {
        di as err "-sjlatex- package is required. To install the package, type"
        di _n `"    {stata "net install sjlatex, from(http://www.stata-journal.com/production)"}"'
        di ""
        exit 499
    }

    // initialize globals
    mata: rdoc_init(st_local("anything"), st_local("prefix"))

    // initialize rdoc output file
    mata: mm_outsheet(st_global("Rdoc_docname"), J(0, 0, ""), "`replace'")
    di as txt `"(rdoc output file is ${Rdoc_docname})"'
end

program rdoc_close
    if `"`macval(0)'"'!="" error 198
    if `"${Rdoc_docname}"'=="" {
        di as txt "(rdoc not initialized; nothing to do)"
        exit
//        di as error "rdoc not initialized"
//        exit 499
    }
    if `"${Rdoc_stname}"'!="" {
        capt rdoc_stlog_close
    }
    di as txt `"(rdoc output written to {browse `"${Rdoc_docname}"'})"'
    global Rdoc_docname      ""
    global Rdoc_docpath      ""
    global Rdoc_stcounter    ""
    global Rdoc_stprefix     ""
end

program rdoc_stlog
    gettoken subcmd args : 0, parse(",: ")
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'==substr("close",1,max(`length',1)) {
        rdoc_stlog_close`macval(args)'
    }
    else if `"`subcmd'"'==substr("oom",1,max(`length',1)) {
        rdoc_stlog_oom`macval(args)'
    }
    else if `"`subcmd'"'=="cnp" {
        rdoc_stlog_cnp`macval(args)'
    }
    else {
        rdoc_stlog_open `macval(0)'
    }
end

program rdoc_stlog_open
    if `"${Rdoc_docname}"'=="" {
        di as txt "(rdoc not initialized; nothing to do)"
        exit
//        di as error "rdoc not initialized"
//        exit 499
    }
    if `"`0'"'!="" {
        global Rdoc_stname `0'
    }
    else {
        local cnterr 0
        if `"${Rdoc_stcounter}"'=="" {
            local cnterr 1
        }
        else {
            capt confirm integer number ${Rdoc_stcounter}
            if _rc local cnterr 1
            else {
                if ${Rdoc_stcounter} < 1 local cnterr 1
            }
        }
        if `cnterr' {
            di as error "something's wrong; invalid rdoc stlog counter"
            exit 499
        }
        global Rdoc_stname    `"${Rdoc_stprefix}${Rdoc_stcounter}"'
    }
    tex \begin{stlog}
    tex \input{${Rdoc_stname}.log.tex}
    tex \end{stlog}
    mata: st_local("tmp", ///
        pathjoin(st_global("Rdoc_path"), st_global("Rdoc_stname")))
    di as txt `"(opening rdoc stlog `tmp')"'
    sjlog using `"`tmp'"', replace
end

program rdoc_stlog_oom
    quietly `macval(0)'
    di _n as txt "\Rdoc_OOM"
end

program rdoc_stlog_cnp
    if `"`macval(0)'"'!="" error 198
    di as txt "\Rdoc_CNP"
end

program rdoc_stlog_close
    if `"`macval(0)'"'!="" error 198
    if `"${Rdoc_docname}"'=="" {
        di as txt "(rdoc not initialized; nothing to do)"
        exit
//        di as error "rdoc not initialized"
//        exit 499
    }
    sjlog close, replace noclean nologfile
    if `"${Rdoc_stname}"'!="" {
        mata: st_local("tmp", ///
            pathjoin(st_global("Rdoc_path"), st_global("Rdoc_stname")))
        mata: rdoc_striplog(st_local("tmp") + ".log.tex")
        capt erase `"`tmp'.smcl"'
        mata: display("{txt}(rdoc stlog written to {browse " + "`" + `"""' + ///
            st_local("tmp") + ".log.tex" + `"""' + "'" + "})")
        global Rdoc_stname ""
        global Rdoc_stcounter = ${Rdoc_stcounter} + 1
    }
end

program rdoc_strip
    syntax [anything] [, Replace ]
    gettoken in out : anything
    gettoken out rest : out
    if `"`rest'"'!="" error 198
    if `"`in'"'=="" | `"`out'"'==""  {
        di as err "must specify input filename and output filename"
        exit 198
    }
    if `"`replace'"'=="" {
        confirm new file `"`out'"'
    }
    mata: rdoc_striptex(`"`in'"', `"`out'"')
end

program rdoc_do
    version 9.2
    local caller : di _caller()
    syntax anything(name=dofile id="filename" everything equalok) ///
        [, Init(str) Replace Prefix(passthru) Close Savecmd(str) ]
    if `"`init'"'!="" {
        rdoc init `init', `replace' `prefix'
    }
    if `"`savecmd'"'!="" {
        mata: st_local("savecmdsuffix", pathsuffix(st_local("savecmd")))
        if `"`savecmdsuffix'"'=="" {
            mata: st_local("savecmd", st_local("savecmd") + ".do")
        }
        capt confirm new file `"`savecmd'"'
        if _rc {
            if "`replace'"!="" erase `"`savecmd'"'
            else confirm new file `"`savecmd'"'
        }
    }
    tempfile dobuf
    local dodobuf 0
    local dopos 0
    local savecmdwrite w
    while (`dopos'<.) {
        mata: rdoc_do()
        if (`dodobuf') {
            version `caller': do `"`dobuf'"'
            local dodobuf 0
        }
        local savecmdwrite a
    }
    if `"`close'"'!="" {
        rdoc close
    }
end

version 9.2
mata:
mata set matastrict on

void rdoc_init(string scalar fn, string scalar stprefix)
{
    string scalar path, fname, suffix

    pathsplit(fn, path, fname)
    suffix = pathsuffix(fname)
    if (suffix=="")   fname = fname + ".tex"
    if (stprefix=="") stprefix = pathrmsuffix(fname) + "_"
    st_global("Rdoc_path", path)
    st_global("Rdoc_docname", pathjoin(path, fname))
    st_global("Rdoc_stcounter", "1")
    st_global("Rdoc_stprefix", stprefix)
    st_global("Rdoc_stname", "")
}

void rdoc_striplog(string scalar fn)
{
    real scalar      i, l
    real colvector   p
    string scalar    s
    string rowvector f

    f = cat(fn)
    if (rows(f)<1) return
    p = J(rows(f),1,1)
    if (f[1]=="{\smallskip}") p[1] = 0  // strip first line
    for (i=1; i<=rows(f); i++) {
        s = f[i]
        if      (s=="\\Rdoc_OOM") f[i] = "\oom"
        else if (s=="\\Rdoc_CNP") f[i] = "\cnp"
        else if (substr(s,1,1)==".") {
            s = tokens(s)
            if (length(s)<4) continue
            l = max((1, strlen(s[3])))
            if (s[1..2]==(".", "rdoc") & s[3]==substr("stlog", 1, l)) {
                l = max((1, strlen(s[4])))
                if (s[4]==substr("close", 1, l) | s[4]=="cnp") {
                    if (length(s)==4) p[i] = 0
                }
                else if (s[4]==substr("oom", 1, l)) {
                    f[i] = "." + substr(f[i], strpos(f[i], " "+s[4])+strlen(s[4])+1, .)
                }
            }
        }
    }
    mm_outsheet(fn, select(f, p), "replace")
}

void rdoc_striptex(string scalar in, string scalar out)
{
    real scalar      i, texmode, texstartl, texstopl
    real colvector   p
    string scalar    texstop, texstart
    string rowvector s
    string colvector f

    texstart = "/*tex"
    texstop  = "tex*/"
    texstartl = strlen(texstart) + 1
    texstopl  = strlen(texstop) + 1
    texmode = 0

    f = cat(in)
    if (rows(f)<1) return
    p = J(rows(f),1,1)
    for (i=1; i<=rows(f); i++) {
        if (texmode) {
            p[i] = 0
            s = strrtrim(f[i])
            if (texstopl<=strlen(s)) s = strltrim(substr(s,-texstopl,.))
            if (s==texstop) texmode = 0
            continue
        }
        s = strltrim(f[i])
        if (strrtrim(substr(s,1,texstartl))==texstart) {
            p[i] = 0
            texmode = 1
            i-- //! closing tag may be on same line
            continue
        }
        if (strrtrim(substr(s, 1, strlen("tex")+1))=="tex") {       // tex ...
            p[i] = 0
            continue
        }
        if (strrtrim(substr(s, 1, strlen("rdoc")+1))=="rdoc") { // rdoc ...
            s = tokens(s)
            if (length(s)<3) {
                p[i] = 0
                continue
            }
            if (s[1]==("rdoc")                 // rdoc s[tlog] o[om]
                & s[2]==substr("stlog", 1, max((1, strlen(s[2]))))
                & s[3]==substr("oom", 1, max((1, strlen(s[3]))))) {
                    f[i] = substr(f[i], strpos(f[i], " "+s[3])+strlen(s[3])+2, .)
            }
            else p[i]=0
        }
    }
    mm_outsheet(out, select(f, p), "replace")
    display(`"{txt:(output written to {browse ""'+out+`""})}"')
}

void rdoc_do()
{
    real scalar     texmode, fh, fhdobuf, hasdo, fhrdoc, fhsavedo,
                    texstartl, texstopl, rc, hastexstart, hastexstop, dopos, dopos0
    string scalar   caller, dofile, rdoc, dobuf, line,
                    s, rest, texstart, texstop, savedo

    //caller = st_local("caller")
    dofile = st_local("dofile")
    dobuf  = st_local("dobuf")
    dopos  = strtoreal(st_local("dopos"))
    if (pathsuffix(dofile)=="") dofile = dofile + ".do"

    texstart = "/*tex"
    texstop  = "tex*/"
    texstartl = strlen(texstart) + 1
    texstopl  = strlen(texstop) + 1
    texmode = 0

    unlink(dobuf)
    fhdobuf = fopen(dobuf, "w")
    hasdo = 0

    savedo = st_local("savecmd")
    if (savedo!="") {
        fhsavedo = fopen(savedo, st_local("savecmdwrite"))
    }

    fh = fopen(dofile, "r")
    fseek(fh, dopos, -1)
    while ((line = fget(fh))!=J(0,0,"")) {
        dopos0 = dopos
        dopos = ftell(fh)
        s = strtrim(line)
        hastexstart = (strrtrim(substr(s,1,texstartl))==texstart)
        hastexstop  = ((texstopl<=strlen(s) ? strltrim(substr(s,-texstopl,.)) : s)==texstop)
        if (texmode==0) {
            if (hastexstart) {
                texmode++
                fclose(fhdobuf)
                if (hasdo) {
                    st_local("dopos", strofreal(dopos0))
                    st_local("dodobuf","1")
                    fclose(fh)
                    if (fhsavedo<.) fclose(fhsavedo)
                    return
                }
                rdoc = st_global("Rdoc_docname")
                if (rdoc!="") fhrdoc = fopen(rdoc, "a")
                line = strtrim(substr(line, strpos(line, texstart)+texstartl, .))
                if (line=="") continue // skip line if empty
            }
            else {
                fput(fhdobuf, line)
                hasdo = 1
                if (fhsavedo<.) fput(fhsavedo, line)
                continue
            }
        }
        else {
            if (hastexstart) texmode++
        }
        if (hastexstop)  texmode--
        if (texmode==0) {
            if (rdoc!="") {
                rest = strtrim(substr(line, 1, strpos(line, texstop)-2))
                if (rest!="") fput(fhrdoc, rest)
                fclose(fhrdoc)
            }
            unlink(dobuf)
            fhdobuf = fopen(dobuf, "w")
            hasdo = 0
        }
        else if (rdoc!="") {
            fput(fhrdoc, line)
        }
    }
    fclose(fh)
    if (fhsavedo<.) fclose(fhsavedo)
    st_local("dopos", ".")
    if (texmode==0) {
        fclose(fhdobuf)
        if (hasdo) st_local("dodobuf","1")
    }
    else {
        if (rdoc!="") fclose(fhrdoc)
    }
    if (fhsavedo<.) {
        display("{txt}(Stata commands written to {browse " + ///
            "`" + `"""' + savedo + `"""' + "'"  + "})")
    }
}

end

* -------------------------------------------------------------------------
* The functions below have been copied from the -moremata- package
* (see -ssc describe moremata-).
* -------------------------------------------------------------------------

* mm_outsheet.mata
* version 1.0.4, Ben Jann, 14apr2006
version 9.0
mata:

void mm_outsheet(string scalar fn, string matrix s,
 | string scalar mode0, string scalar del)
{
        string scalar line, mode, m
        real scalar i, j, fh

        if (args()<4) del = char(9)
        mode = mm_strexpand(mode0, ("append", "replace"))
        m = "w"
        if (mode=="replace") unlink(fn)
        else if (mode=="append") m = "a"
        fh = fopen(fn, m)
        for (i=1; i<=rows(s); i++) {
                line = J(1,1,"")
                for (j=1; j<=cols(s); j++) {
                        line = line + s[i,j]
                        if (j<cols(s)) line = line + del
                }
                fput(fh, line)
        }
        fclose(fh)
}
end

* mm_strexpand.mata
* version 1.0.4, Ben Jann, 30apr2007
version 9.0
mata:

string scalar mm_strexpand(string scalar s, string vector slist,
 | string scalar def, real scalar unique, string scalar errtxt)
{
    real scalar   err
    string scalar res

    if (args()<5) errtxt = `"""' + s + `"" invalid"'
    if (args()<4) unique = 0
    err = _mm_strexpand(res, s, slist, def, unique)
    if (err) _error(err, errtxt)
    return(res)
}

real scalar _mm_strexpand(res, string scalar s,
 string vector slist, | string scalar def, real scalar unique)
{
    real scalar i, l, match

    if (s=="") {
        res = def
        return(0)
    }
    if (args()<5) unique = 0
    l = strlen(s)
    if (unique) {
        match = 0
        for (i=1; i<=length(slist); i++) {
            if (s==substr(slist[i], 1, l)) {
                if (match) return(3498)
                match = i
            }
        }
        if (match) {
            res = slist[match]
            return(0)
        }
    }
    else {
        for (i=1; i<=length(slist); i++) {
            if (s==substr(slist[i], 1, l)) {
                res = slist[i]
                return(0)
            }
        }
    }
    return(3499)
}
end
