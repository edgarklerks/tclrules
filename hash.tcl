package provide hash 1.0 
package require critcl 


critcl::ccommand hashValInc {cd interp objc objv} {
    if (objc != 3) {
        Tcl_AddErrorInfo(interp, "too many arguments to hashVal");
        return TCL_ERROR;
    }


    int slen = 0;
    const char * hv = Tcl_GetByteArrayFromObj(objv[2],&slen);
    unsigned long hash = 0;
    Tcl_GetLongFromObj(interp, objv[1], &hash);

    for (int i = 0; i < slen; i++){
        int c = *(hv + 1);
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    }
    Tcl_SetObjResult(interp,Tcl_NewLongObj(hash));

    return TCL_OK;

}

critcl::ccommand hashVal {cd interp objc objv} {
    if (objc != 2) {
        Tcl_AddErrorInfo(interp, "too many arguments to hashVal");
        return TCL_ERROR;
    }


    int slen = 0;
    const char * hv = Tcl_GetByteArrayFromObj(objv[1],&slen);
    unsigned long hash = 5381;

        for (int i = 0; i < slen; i++){
        int c = *(hv +i);
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    }
    Tcl_SetObjResult(interp,Tcl_NewLongObj(hash));
    return TCL_OK;

}