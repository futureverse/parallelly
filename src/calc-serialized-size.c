// Adopted from https://github.com/coolbutuseless/serializer
// which is released under the MIT license

#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#ifndef R_INT_MAX
#define R_INT_MAX  INT_MAX
#endif


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Write a byte into the buffer at the current location.
// The actual buffer is encapsulated as part of the stream structure, so you
// have to extract it first
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void count_byte(R_outpstream_t stream, int c) {
  error("count_byte(): This function is never called for binary serialization");
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Write multiple bytes into the buffer at the current location.
// The actual buffer is encapsulated as part of the stream structure, so you
// have to extract it first
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void count_bytes(R_outpstream_t stream, void *src, int length) {
  R_xlen_t *count = (R_xlen_t *)stream->data;
  *count += length;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Serialize an R object, but only count the bytes.  
// This function is only visible to C code
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
R_xlen_t calc_serialized_size(SEXP robj) {
  // Initialise the count
  R_xlen_t count = 0;

  // Create the output stream structure
  struct R_outpstream_st output_stream;

  // Initialise the output stream structure
  R_InitOutPStream(
    &output_stream,            // The stream object which wraps everything
    (R_pstream_data_t) &count, // user data that persists within the process
    R_pstream_binary_format,   // Store as binary
    3,                         // Version = 3 for R >3.5.0 See `?base::serialize`
    count_byte,                // Function to write single byte to buffer
    count_bytes,               // Function for writing multiple bytes to buffer
    NULL,                      // Func for special handling of reference data.
    R_NilValue                 // Data related to reference data handling
  );

  // Serialize the object into the output_stream
  R_Serialize(robj, &output_stream);

  return count;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Serialize an R object, but only count the bytes. 
// This function is callable from R
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SEXP R_calc_serialized_size(SEXP robj) {
  R_xlen_t count = calc_serialized_size(robj);
  return(ScalarReal((double) count));
}
