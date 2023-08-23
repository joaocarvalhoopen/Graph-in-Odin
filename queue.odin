// Name:                          Graph in Odin
// Autor of the port:             Joao Carvalho
// Autor of the original version: Tharaka Ratnayake
// 
// Description: A port of graph-c originally written in C from
//              Tharaka Ratnayake to the Odin programming Language.
//              This source code contain some templates that where 
//              by me and by several members of the Odin community.
//              In a one night most fruitefull discussion in the Odin
//              discord channel members in the begginers forum.
//
//              Original source code in C can be found at:
// 
//              Github tharaka27 / graph-c
//              Tharaka Ratnayake 
//              https://github.com/tharaka27/graph-c
//
//
// Date: 2023-08-23
// License: MIT Open Source License
//
// How to compile it:
//
//      $ make
//
// How to run it:
//
//      $ make run
//


package graph_odin

import "core:fmt"
import "core:strings"
import "core:os"
import "core:text/scanner"
import "core:strconv"
import "core:intrinsics"


// IMPORTANT: This generics (parapoly) in Odin where the result of the
//            iteration of the problem of this function trught several
//            senior members of the Odin community, at the Odin Discord
//            beginners group.

my_sscanf_string :: proc ( $T: typeid ) -> ( res_str: string, ok: bool ) {
	buf: [256]byte
	n, err := os.read(os.stdin, buf[:])
	if err < 0 {
		// Handle error
		return "", false
	}

    // fmt.printf("buf: %v   buf[0]: [%v]\n", buf[ : n ], rune( buf[0] ) )

    // Conditional compilation, early exit.
    when T == string {
        return string( buf[ :n ] ), true
    }

    // input := " 124.777"
    input := string( buf[ :n ] )
    txt: scanner.Scanner
    scanner.init( & txt, input )

    my_type_of_scanner := scanner.Int
    
    // Conditional compilation.
    when T == int {
        txt.flags = { .Scan_Ints }
        my_type_of_scanner = scanner.Int
    } else when T == f32 || T == f64 {
        txt.flags = { .Scan_Floats }
        my_type_of_scanner = scanner.Float
    } else {
        fmt.eprintf("Error: my_sscanf_type type not supported\n")
        os.exit( EXIT_FAILURE )
    }

    txt.whitespace = scanner.Odin_Whitespace 

    // if scanner.scan( & txt ) == my_type_of_scanner
    if scanner.scan( & txt ) != '\n'
    {
        // Continuation of the "when"...
        token_str := scanner.token_text( & txt )

        token_str_heap := strings.clone(token_str)

        // fmt.printf( "token_str: [%v]\n", token_str )

        return token_str_heap, true
    }
    // Note: This string is a literal string so it is not allocated in the heap.
    //       So it doesn't, and shouldn't be need to be deleted.
    return "", false
}


//---------------
// Version 1

// This restricts the input type to only int or f32 or f64 with the where clause.
my_sscanf_type_1 :: proc ( $T: typeid ) -> ( res_val: T, res_ok: bool )
    where T == int || T == f32 || T == f64 
    {
    ZERO :: 0

    str_tmp, ok_1 := my_sscanf_string( T )
    defer delete( str_tmp )
    // fmt.printf("Error_! : [%v, %v]\n", str_tmp, ok_1)
    if !ok_1 {
        return T(ZERO), false
    }

    // Runtime selection of the type.
    switch typeid_of(T) {
    case int :
        val_2, ok_2 := strconv.parse_int( str_tmp )
        if !ok_2 {
            // fmt.printf("Error_2 : [%v, %v]\n", val_2, ok_2)
            return ZERO, false
        }
        return T(val_2), true
    case f64 :
        val_3, ok_3 := strconv.parse_f64( str_tmp )
        if !ok_3 {
            return ZERO, false
        }
        return T(val_3), true
    case f32 :
            val_4, ok_4 := strconv.parse_f32( str_tmp )
            if !ok_4 {
                return ZERO, false
            }
            return T(val_4), true    
    case:
        fmt.eprintf("Error: my_sscanf_type type not supported\n")
        os.exit( EXIT_FAILURE )
    }
}

//---------------
// Version 2

// This restricts the input type to only int or f32 or f64 with the where clause.
// This one doesn't use the case and is compile time type evaluated with the when T == int,
// so it is faster because it doesn't have a compile time switch on the typeid_of(T).
my_sscanf_type_2 :: proc ( $T: typeid ) -> ( res_val: T, res_ok: bool )
    where T == int || T == f32 || T == f64 
    {
    ZERO :: 0

    str_tmp, ok_1 := my_sscanf_string( T )
    defer delete( str_tmp )
    if !ok_1 {
        return T(ZERO), false
    }
    
    // Compile time selection of the type.
    when T == int {
        val_2, ok_2 := strconv.parse_int( str_tmp )
        if !ok_2 {
            return ZERO, false
        }
        return T(val_2), true
    } else when T == f64 {
        val_3, ok_3 := strconv.parse_f64( str_tmp )
        if !ok_3 {
            return ZERO, false
        }
        return T(val_3), true
    } else when T == f32 {
        val_4, ok_4 := strconv.parse_f32( str_tmp )
        if !ok_4 {
            return ZERO, false
        }
        return T(val_4), true    
    } else {
        fmt.eprintf("Error: my_sscanf_type type not supported\n")
        os.exit( EXIT_FAILURE )
    }
}


//---------------
// Version 3

// This seems to be the best and most simple implementation.
my_sscanf_type_3 :: proc( $T: typeid ) -> ( value: T, ok: bool ) 
    where T == int || T == f32 || T == f64
{
    str_tmp := my_sscanf_string( T ) or_return
    defer delete( str_tmp )

    // Compile time selection of the type.
    // With elegant error handling. 
    when T == int {
        value = strconv.parse_int(str_tmp) or_return
    } else when T == f32 {
        value = strconv.parse_f32(str_tmp) or_return
    } else when T == f64 {
        value = strconv.parse_f64(str_tmp) or_return
    } else {
        // fmt.panic("my_sscanf_type type not supported")
        #panic("my_sscanf_type type not supported")
    }

  return value, true
}


//---------------
// Version 4

// This seems to be the most complicated and is a runtime selection of the type,
// with a hashtable of function pointers.
// But in Odin evrything is super simple.
parse_int :: proc( s: string ) -> ( int, bool ) { return strconv.parse_int(s);   }
parse_f32 :: proc( s: string ) -> ( f32, bool ) { return strconv.parse_f32(s);   }
parse_f64 :: proc( s: string ) -> ( f64, bool ) { return strconv.parse_f64(s); }

parsers := map [typeid] rawptr {
  int = cast(rawptr) parse_int,
  f32 = cast(rawptr) parse_f32,
  f64 = cast(rawptr) parse_f64,
};

parse_str :: proc( str: string, $T: typeid ) -> ( T, bool ) {
  return ((proc (str: string) -> (T, bool)(parsers[T]))(str))
}

my_sscanf_type_4 :: proc( $T: typeid ) -> ( value: T, ok: bool ) 
    where T == int || T == f32 || T == f64
{
  str_tmp := my_sscanf_string( T ) or_return
  defer delete( str_tmp )
  value = parse_str( str_tmp, T ) or_return
  return value, true
}

//--------------------------------
// Beginning of normal program.

EXIT_SUCCESS :: 0
EXIT_FAILURE :: 1

Node :: struct {
    info : int,
    ptr : ^Node
}

Queue :: struct {
    front  : ^Node,
    rear   : ^Node,
    temp   : ^Node,
    front1 : ^Node,
    count  : int
}
  
// Make an empty queue.
queue_make :: proc () -> ^Queue {
    qu : ^Queue = new(Queue)
    qu.front  = nil
    qu.rear   = nil
    qu.temp   = nil
    qu.front1 = nil
    qu.count  = 0
    return qu
}

queue_destroy :: proc ( qu : ^Queue ) {
    // Clean all queue nodes.
    for {
        _, ok := queue_deq( qu, no_error_message = true )
        if !ok {
            break
        }
        // fmt.printf("ok: [%v]\n", ok)
    }

    qu.front  = nil
    qu.rear   = nil
    qu.temp   = nil
    qu.front1 = nil
    qu.count  = 0
    free( qu )
} 

// Get queue size.
queue_size :: proc ( qu : ^Queue ) -> int {
    fmt.printf("Queue size : %v\n", qu.count)
    return qu.count
}
 
// Enqueing the queue.
queue_enq :: proc ( qu : ^Queue, data : int) {
    if qu.rear == nil {
        qu.rear = new( Node )
        qu.rear.ptr = nil
        qu.rear.info = data
        qu.front = qu.rear
    } else {
        qu.temp = new( Node )
        qu.rear.ptr = qu.temp
        qu.temp.info = data
        qu.temp.ptr = nil
 
        qu.rear = qu.temp
    }
    qu.count += 1
}
 
// Displaying the queue elements.
queue_display :: proc ( qu : ^Queue ) {
    qu.front1 = qu.front;
 
    if (qu.front1 == nil) && (qu.rear == nil) {
        fmt.printf("Queue is empty\n");
        return;
    }
    for qu.front1 != qu.rear {
        fmt.printf("%v ", qu.front1.info)
        qu.front1 = qu.front1.ptr
    }
    if qu.front1 == qu.rear {
        fmt.printf("%v", qu.front1.info)
    }
    fmt.printf("\n count: %v\n", qu.count)
}

// Dequeing the queue.
queue_deq :: proc ( qu : ^Queue, no_error_message: bool = false ) -> ( res: int, ok: bool ) {   
    w : int
    qu.front1 = qu.front
 
    if qu.front1 == nil {
        if !no_error_message {
            fmt.printf("\n Error: Trying to display elements from empty queue\n")
        }
        return 123456789, false 
    }
    if qu.front1.ptr != nil {
        qu.front1 = qu.front1.ptr
        // fmt.printf("\n Dequed value : %v", qu.front.info )
        w = qu.front.info
        free( qu.front )
        qu.front = qu.front1
    } else {
        // fmt.printf("\n Dequed value : %v", qu.front.info )
        w = qu.front.info
        free( qu.front )
        qu.front = nil
        qu.rear = nil
    }
    qu.count -= 1
    return w, true
}

// Returns the front element of queue.
queue_front_element :: proc ( qu : ^Queue ) -> int {
    if (qu.front != nil ) && (qu.rear != nil) {
        return qu.front.info
    }
    return 0
}
 
// Display if queue is empty or not.
queue_is_empty :: proc ( qu : ^Queue ) {
    if (qu.front == nil) && (qu.rear == nil) {
        fmt.printf("\n Queue empty\n")
    } else {
       fmt.printf("Queue not empty\n")
    }
}

// ----------------------------------------------------------------------------

queue_main :: proc () {
    fmt.printf("\n")
    fmt.printf(" 1 - Enque\n")
    fmt.printf(" 2 - Deque\n")
    fmt.printf(" 3 - Front element\n")
    fmt.printf(" 4 - Empty\n")
    fmt.printf(" 5 - Exit\n")
    fmt.printf(" 6 - Display\n")
    fmt.printf(" 7 - Queue size\n")
    
    qu : ^Queue = queue_make()
    for {
        fmt.printf("\n Enter choice : ")
        // ch : rune
        // scanf("%d", &ch);
        ch, ok := my_sscanf_type_4(int)

        // fmt.printf("ch: [%v] and ok: [%v]\n", ch, ok)

        if !ok {
            fmt.printf("Error: my_sscanf_int failed\n")
            continue
        } 
        switch ch {
        case 1:
            fmt.printf("Enter data : ")
            // scanf("%d", &no)
            no, ok_2 := my_sscanf_type_1(int)
            if !ok_2 {
                fmt.printf("Error: my_sscanf_type failed\n")
            }
            queue_enq( qu, no )
        case 2:
            queue_deq( qu )
        case 3:
            e: int
            e = queue_front_element( qu )
            if e != 0 {
               fmt.printf("Front element : %d", e)
            } else {
               fmt.printf("\n No front element in Queue as queue is empty")
            }
        case 4 :
            queue_is_empty( qu )
        case 5:
            queue_destroy( qu )
            os.exit( EXIT_SUCCESS )
        case 6:
            queue_display( qu )
        case 7:
            queue_size( qu )
        
        // default
        case:
            fmt.printf("Wrong choice, Please enter correct choice \n")
        }
    }
}
