// Copyright (c) 2023-present K. S. Ernest (iFire) Lee
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "erl_nif.h"
#include "unifex.h"

// Define the Erlang resource type for your Unifex resource
static ErlNifResourceType* godot_instance_term = NULL;

// Store the PID of the pointer storage process
static ErlNifPid pointer_storage_pid;

// Unifex C function to call a method on a Godot class instance
UNIFEX_TERM call_instance_method(UnifexEnv *env, UnifexResource *instance, const char *method_name, ERL_NIF_TERM args) {
    // Cast the Unifex resource to your resource type
    GodotInstanceTerm *res = (GodotInstanceTerm*)instance->data;

    // Look up the pointer in the storage process using the resource ID
    ERL_NIF_TERM pointer_id = enif_make_ulong(env, res->id);
    ERL_NIF_TERM result;
    if (enif_send(env, &pointer_storage_pid, NULL, enif_make_tuple2(env, enif_make_atom(env, "get_pointer"), pointer_id))) {
        if (enif_receive(env, NULL, ERL_NIF_TERM_MAX, &result)) {
            if (enif_is_binary(env, result)) {
                // Call the method using the retrieved pointer
                void *pointer = enif_make_binary(env, &result);
                // Your C code to call a method on a Godot class instance using the retrieved pointer
            } else {
                return result;
            }
        } else {
            return enif_make_atom(env, "error");
        }
    } else {
        return enif_make_atom(env, "error");
    }

    return enif_make_atom(env, "ok");
}

// Unifex C function to call a static method on a Godot class
UNIFEX_TERM call_static_method(UnifexEnv *env, const char *class_name, const char *method_name, ERL_NIF_TERM args) {
    // Look up the pointer in the storage process using the class name
    ERL_NIF_TERM pointer_id = enif_make_binary(env, class_name);
    ERL_NIF_TERM result;
    if (enif_send(env, &pointer_storage_pid, NULL, enif_make_tuple2(env, enif_make_atom(env, "get_pointer"), pointer_id))) {
        if (enif_receive(env, NULL, ERL_NIF_TERM_MAX, &result)) {
            if (enif_is_binary(env, result)) {
                // Call the method using the retrieved pointer
                void *pointer = enif_make_binary(env, &result);
                // Your C code to call a static method on a Godot class using the retrieved pointer
            } else {
                return result;
            }
        } else {
            return enif_make_atom(env, "error");
        }
    } else {
        return enif_make_atom(env, "error");
    }

    return enif_make_atom(env, "ok");
}

// Unifex C function to instantiate a Godot class and store the pointer in the storage process
UNIFEX_TERM instantiate_class(UnifexEnv *env, const char *class_name) {
    // Instantiate the class using your existing code
    void *pointer = // Your C code to instantiate a Godot class
    if (pointer != NULL) {
        ErlNifBinary binary_pointer;
        enif_alloc_binary(sizeof(void*), &binary_pointer);
        memcpy(binary_pointer.data, &pointer, sizeof(void*));

        ERL_NIF_TERM result;
        if (enif_send(env, &pointer_storage_pid, NULL, enif_make_tuple2(env, enif_make_atom(env, "store_pointer"), enif_make_binary(env, &binary_pointer)))) {
            if (enif_receive(env, NULL, ERL_NIF_TERM_MAX, &result)) {
                if (enif_is_tuple(env, result)) {
                    const ERL_NIF_TERM* tuple;
                    int arity;
                    if (enif_get_tuple(env, result, &arity, &tuple) && arity == 2 && enif_is_atom(env, tuple[0]) && enif_is_integer(env, tuple[1])) {
                        if (enif_is_identical(tuple[0], enif_make_atom(env, "ok"))) {
                            unsigned long id;
                            if (enif_get_ulong(env, tuple[1], &id)) {
                                GodotInstanceTerm *res = enif_alloc_resource(godot_instance_term, sizeof(GodotInstanceTerm));
                                res->id = id;
                                res->pointer = pointer;
                                return enif_make_resource(env, res);
                            }
                        }
                    }
                }
            }
        }

        // Error handling
        // ...
    }

    // Error handling
    return enif_make_atom(env, "error");
}
