GSSAPI="BASE"  # This ensures that a full module is generated by Cython

from gssapi.raw.cython_types cimport *
from gssapi.raw.cython_converters cimport c_get_mech_oid_set
from gssapi.raw.creds cimport Creds

from gssapi.raw.misc import GSSError

cdef extern from "python_gssapi_ext.h":
    OM_uint32 gss_set_neg_mechs(
        OM_uint32 *minor_status,
        gss_cred_id_t cred_handle,
        const gss_OID_set mech_set) nogil


def set_neg_mechs(Creds cred_handle not None, mech_set not None):
    """
    set_neg_mechs(cred_handle not None, mech_set not None)

    Specify the set of security mechanisms that may be negotiated with
    the credential identified by cred_handle.
    If more than one mechanism is specified in mech_set, the order in
    which those mechanisms are specified implies a relative preference.

    Args:
        cred_handle (Creds): credentials to set negotiable mechanisms for
        mech_set (~gssapi.MechType): negotiable mechanisms to be set

    Returns:
        None

    Raises:
        ~gssapi.exceptions.GSSError
    """

    cdef gss_OID_set negotiable_mechs = c_get_mech_oid_set(mech_set)

    cdef OM_uint32 maj_stat, min_stat

    with nogil:
        maj_stat = gss_set_neg_mechs(&min_stat, cred_handle.raw_creds,
                                     negotiable_mechs)

    cdef OM_uint32 tmp_min_stat
    gss_release_oid_set(&tmp_min_stat, &negotiable_mechs)

    if maj_stat == GSS_S_COMPLETE:
        return None
    else:
        raise GSSError(maj_stat, min_stat)
