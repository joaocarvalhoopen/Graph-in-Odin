// Name:                          Graph in Odin
// Autor of the port:             Joao Carvalho
// Autor of the original version: Tharaka Ratnayake
// 
// Description: A port of graph-c originally written in C from
//              Tharaka Ratnayake to the Odin programming Language.
//              This source code contain some templates that where 
//              by me and by several members of the Odin community.
//              In a one night most fruitefull discussion in the Odin
//              discord channel in the begginers forum.
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
import "core:strconv"


// The MAX number of vertices that can go out of a node.
MAXV :: 100

main :: proc () {
    // Queue main.
    // queue_main()

    // Graph main.
    graph_main()
}

graph_main :: proc ( )  {
    path : string = "graph.txt"
    my_g1 : ^Graph_t = nil
    my_g2 : ^Graph_t = nil

    if len(os.args) != 2 {
        fmt.printf("Usage: %v graph_file_name\n", os.args[ 0 ] )
        os.exit( EXIT_FAILURE )
    }
    path = os.args[1]
    my_g1 = new(Graph_t)
    defer free( my_g1 )
    if my_g1 == nil {
        fmt.eprintf( "Cannot allocate memory for the graph\n" )
        os.exit( EXIT_FAILURE )
    }
    initialize_graph(my_g1, false )
    read_graph( my_g1, path)
    print_graph(my_g1, "my_g1")
}

// -------------------
// Graph implementation

/* Function implemented:

    initialize_graph :: proc ( g: ^Graph_t, directed: bool )
    read_graph       :: proc (g : ^Graph_t, filename : string)
    insert_edge      :: proc ( g : ^Graph_t, x : int, y : int, w : int )
    print_graph      :: proc (g : ^Graph_t , name : string )
    free_graph       :: proc ( g : ^Graph_t )
    delete_edge      :: proc ( g : ^Graph_t, from : int , to : int )
    print_degree     :: proc (g : ^Graph_t )
    print_complement :: proc (g : ^Graph_t, p : int )
    eliminate_links  :: proc (g : ^Graph_t , minW : int, maxW : int )
    different_links  :: proc (g : ^Graph_t , c : ^Graph_t )
    commonl_inks     :: proc (g : ^Graph_t , c : ^Graph_t )
    dfs              :: proc ( g : ^Graph_t, k : int )
    bfs              :: proc ( g : ^Graph_t, k : int )
    is_connected     :: proc ( g : ^Graph_t ) -> bool
    num_of_conn_comp :: proc (g : ^Graph_t )
    copy_graph       :: proc (g : Graph_t) -> ^Graph_t

    */

visited : [6]bool

Edge_node_t :: struct {
    y      : int,
    weight : int,
    next   : ^Edge_node_t
}

Graph_t :: struct {
    edges     : [ MAXV + 1 ]^Edge_node_t,
    degree    : [ MAXV + 1 ]int,
    nvertices : int,
    nedges    : int,
    directed  : bool
}

initialize_graph :: proc ( g: ^Graph_t, directed: bool ) {
    i : int
    g.nvertices = 0
    g.nedges = 0
    g.directed = directed
    for i=1; i <= MAXV ; i += 1 {
        g.edges[i] = nil
    }
    for i=1; i <= MAXV ; i += 1 {
        g.degree[i] = 0
    }
}

read_graph :: proc ( g : ^Graph_t, filename : string ) {
    i : int
    dir : int
    // n, m, dir : int
    // x, y, w : int

    data, ok := os.read_entire_file_from_filename( filename )
    defer delete( data )
    if !ok {
        // To know the current present working diretory.
        // os.execvp( "pwd", []string{ "pwd", "" } )
        fmt.eprintf( "Cannot open the graph file... \n%v\n", filename )
        os.exit( EXIT_FAILURE )
    }

    data_lines_str := string( data )
    // defer delete( data_lines_str )

    for line, line_num in strings.split_lines( data_lines_str ) {
        if strings.trim( line, " \t" ) == "" {
            continue
        }

        field_slice := strings.split( line, " " )
             
        if line_num == 0 {    
            if len( field_slice ) != 3 {
                fmt.eprintf( 
                    "The first line of the graph file should be in the format of \"n m dir\" with 3 element, present line values %v\n",
                    field_slice )
                os.exit( EXIT_FAILURE )
            }
            n,       ok_1 := strconv.parse_int( field_slice[ 0 ] )
            m,       ok_2 := strconv.parse_int( field_slice[ 1 ] )
            dir_tmp, ok_3 := strconv.parse_int( field_slice[ 2 ] )
            if !ok_1 || !ok_2 || !ok_3 {
                fmt.eprintf( "The first line of the graph file should be valid integers and in the format of \"n m dir\"\n" )
                os.exit( EXIT_FAILURE )
            }
            dir = dir_tmp

            g.nvertices = n
            g.nedges = 0
            g.directed = bool( dir )
            continue
        } else {
            if len( field_slice ) != 3 {
                fmt.eprintf( 
                    "The second line until the end line of the graph file should be in the format of \"x y w\", with 3 element, present values %v\n",
                    field_slice )
                os.exit( EXIT_FAILURE )
            }
            x, ok_1 := strconv.parse_int( field_slice[ 0 ] )
            y, ok_2 := strconv.parse_int( field_slice[ 1 ] )
            w, ok_3 := strconv.parse_int( field_slice[ 2 ] )
            if !ok_1 || !ok_2 || !ok_3 {
                fmt.eprintf( 
                    "The second line until the end line of the graph file should be valid integers and in the format of \"x y z\"\n" )
                os.exit( EXIT_FAILURE )
            }
            // TODO: Implement the scanner.
            insert_edge( g, x, y, w )
            if bool( dir ) == false {
                insert_edge( g, y, x, w )
            }
        }
    }
}

insert_edge :: proc ( g : ^Graph_t, x : int, y : int, w : int ) {
    pe : ^Edge_node_t
    pe = new(Edge_node_t)
    if pe == nil {
        fmt.eprintf( "Cannot allocate memory for the node.\n" );
        os.exit( EXIT_FAILURE )
    }
    pe.weight = w 
    pe.y = y
    // insert_edge has modified in way even if the user inputs
    // in different order to make the linked list in order
    if g.edges[x] == nil {       
        pe.next = g.edges[x]
        g.edges[x] = pe;
    } else {
        // if this node already exists we should not ad it again a value
        checker : ^Edge_node_t
        checker = g.edges[x]
        for checker != nil {
            if checker.y == y {
                return 
            }
            checker = checker.next
        }
        // if there is no node there , then we can add that node
        qe : ^Edge_node_t
        qe = g.edges[x]       
        if qe.y > pe.y {
           pe.next = qe
           g.edges[x] = pe
        } else {
            for ( qe.next != nil ) && (( qe.next.y ) < ( pe.y )){
                qe = qe.next
            }
          pe.next = qe.next
          qe.next = pe
        }
    }
    g.degree[x] += 1
    g.nedges += 1
}


print_graph :: proc (g : ^Graph_t , name : string ) {
    pe : ^Edge_node_t
    i : int
    // If g == nil
    if g == nil   {
       return;
    }
    fmt.printf("Graph Name: %v\n",name)
    for i=1; i <= g.nvertices; i += 1 {
        fmt.printf("Node %v: ",i);
        pe = g.edges[i]
        for pe != nil {
            fmt.printf(" %v(w=%v),", pe.y,pe.weight);
            pe = pe.next;
        }
    fmt.printf("\n");
    }
}

free_graph :: proc ( g : ^Graph_t ) {
    pe, olde : ^Edge_node_t
    i : int
    for i=1; i <= g.nvertices; i += 1 {
        fmt.printf( "Node %v: ",i )
        pe = g.edges[i]
        for pe != nil  {
            olde = pe;
            pe = pe.next
            free( olde )
        }
    free( g )
    }
}

delete_edge :: proc ( g : ^Graph_t, from : int , to : int ) {
    pe : ^Edge_node_t
    
    pe = g.edges[ from ]

    if g.edges[ from ] == nil {
        return 
    } else {
        if pe.y == to {
            g.edges[ from ] = nil
        } else {
            for pe.next.y != to {
                pe = pe.next
            if pe.next.next == nil {
                    pe.next = nil
            } else {
                pe.next = pe.next.next
            }
        }
    }
    g.degree[from] -= 1
    g.nedges -= 1
    }
}

copy_graph :: proc (g : Graph_t) -> ^Graph_t {
    newg : ^Graph_t
    gn : ^Edge_node_t 
    // cn : ^Edge_node_t 
    i : int
    newg = new(Graph_t)
    // I simply return the same graph as a copy
    // but you really need to dynamically create
    // another copy f the given graph
    initialize_graph( newg, g.directed );
 
    newg.nedges = g.nedges
    newg.nvertices = g.nvertices

    for  i = 1 ; i <= g.nvertices ; i += 1 {
        gn = g.edges[i]
        if gn == nil{
            newg.edges[i] = nil
        } else {
            for gn != nil {
                insert_edge( newg, i, gn.y,gn.weight )
                if g.directed == false {
                     insert_edge( newg, gn.y, i, gn.weight )
                }
                gn = gn.next
            }
        }
    }
    return newg
}

print_degree :: proc (g : ^Graph_t ) {
    i : int
    if g.directed == false {
        // for an directed graph
        for i=1 ; i <= g.nvertices; i += 1 {
            fmt.printf( "number of vertices in node %v is %v\n", i , g.degree[i] )
        }
    } else {
        // for an directed graph
        for i=1; i <= g.nvertices; i += 1 {
            fmt.printf("number of vertices in node %v is %v\n", i , g.degree[i] )
        }
    }

}

print_complement :: proc (g : ^Graph_t, p : int ) { 

//  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  +     we create a new instance of the
//  +     new graph. and compare this graph with 
//  +     given g graph using differentlinks(cg,g);
//  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    i, k : int   
    cg : ^Graph_t
    // ge : ^Edge_node_t
    cg = new(Graph_t)
    if cg == nil {
        fmt.eprintf( "Cannot allocate memory for the graph\n" )
        os.exit( EXIT_FAILURE )
    }
    initialize_graph( cg , g.directed )
    cg.directed = g.directed
    cg.nedges = g.nedges
    cg.nvertices = g.nvertices
    for i = 1; i <= g.nvertices; i += 1 {
        for k = 1; k <= g.nvertices; k += 1 {
            insert_edge( cg, i, k, 1 )
        }
    }
    differentlinks( cg, g )
    //print_graph(cg,"complement");  //free_graph(cg); 
}

eliminate_links :: proc (g : ^Graph_t , minW : int, maxW : int ) {
    temp , prev : ^Edge_node_t
    i : int
    for i = 1; i <= 6; i += 1 {
        fmt.printf("%v", i);
        temp = g.edges[ i ]
        for temp != nil && (temp.weight < minW || temp.weight > maxW) {
            g.edges[ i ] = temp.next  // Changed head
            free( temp ) // free old head
            temp = g.edges[ i ]  //change temp
        }
         
        // delete occurence rather than the head
        for temp != nil {
         
            // Search for the node to be deleted, 
            // keep track of the previous node as we 
            // need to change 'prev->next'
            for temp != nil  && ( temp.weight >= minW && temp.weight <= maxW ) {
                prev = temp
                temp = temp.next
            }

            // If required value node was not present
            // in linked list
            if( temp == nil ) {
                break
            }

            // Unlink the node from linked list
            prev.next = temp.next
            g.degree[ i ] -= 1
            free( temp )

            // Update Temp for next iteration of 
            // outer loop
            temp  = prev.next
        }
    }
}

different_links :: proc (g : ^Graph_t , c : ^Graph_t ) {
    gn, cn : ^Edge_node_t
    i : int
    for i = 1; i <= g.nvertices; i += 1 {
        gn = g.edges[ i ]
        cn = c.edges[ i ]
        fmt.printf("Node %v: ", i )
        
        if gn == nil {
           continue
        } else {
            for gn != nil {
               exist : bool = false
               for cn != nil {
                   if gn.y == cn.y {
                       exist = true
                   }
                cn = cn.next
               }
               if exist == false {
                    fmt.printf("%v(w=%v), ", gn.y, gn.weight )       
                }
            cn = c.edges[ i ]
            gn = gn.next
            }
        }
    fmt.printf("\n")
    }
}

common_links :: proc (g : ^Graph_t , c : ^Graph_t ) {
    gn, cn : ^Edge_node_t
    i : int
    for i = 1; i <= g.nvertices; i += 1{
        gn = g.edges[ i ]
        cn = c.edges[ i ]
        fmt.printf( "Node %v: ",i )
        
        if gn == nil {
           continue;
        } else {
            for gn != nil {
               exist: bool = false
               for cn != nil {
                   if gn.y == cn.y {
                       exist = true
                   }
                cn = cn.next
               }
               if exist {
                    fmt.printf("%v(w=%v), ", gn.y, gn.weight )       
                }
            cn = c.edges[ i ]
            gn = gn.next
            }
        }      
    fmt.printf("\n")
    }
}

dfs :: proc ( g : ^Graph_t, k : int ) {
    fmt.printf("%v->",k);
    
    pe : ^Edge_node_t
    pe = g.edges[ k ]
    visited[ k ] = true
    for pe != nil {
        k_tmp := pe.y
        if !visited[ k ] {
            dfs( g, k_tmp )
        }
        pe = pe.next
    }
}

bfs :: proc ( g : ^Graph_t, k : int ) {
    qu : ^Queue = queue_make()
    defer queue_destroy( qu )
    pe : ^Edge_node_t
    pe = g.edges[ k ]
    i : int
    
    // bvisited : [ g.nvertices ]int
    bvisited := make([dynamic]int, g.nvertices )
    defer delete( bvisited )

    w, p : int
    for i= 1; i <= g.nvertices; i+= 1 {
        bvisited[ i ] = 0
    }
    queue_enq( qu, k )
    bvisited[ k ] = 1 
    fmt.printf("\nVisited\t%v", k )

    for queue_size( qu ) != 0 {
        ok : bool
        p, ok = queue_deq( qu )
        pe = g.edges[p]
        for pe != nil {
            w = pe.y 
            if bvisited[ w ] == 0 {
                queue_enq( qu, w )
                bvisited[ w ] = 1
                fmt.printf( "-> %v", w )
            }
            pe = pe.next
        }
    }
}

is_connected :: proc ( g : ^Graph_t ) -> bool {
    if g.directed == true {
        fmt.printf("join the list to get the next version of this program :)");
        return false
    } else {
        connected : bool = true

        qu : ^Queue = queue_make()
        defer queue_destroy( qu )

        pe : ^Edge_node_t
        pe = g.edges[ 1 ]
        i : int
    
        // bvisited : [ g.nvertices ]int
        bvisited := make([dynamic]int, g.nvertices )
        defer delete( bvisited )

        w ,p : int
        for i= 1; i <= g.nvertices; i += 1 {
            bvisited[ i ] = 0
        }
        queue_enq( qu, 1 )
        bvisited[ 1 ] = 1

        for queue_size( qu ) != 0 {
            ok : bool
            p, ok = queue_deq( qu )
            pe = g.edges[ p ]
            for pe != nil {
                w = pe.y
                if bvisited[ w ] == 0 {
                    queue_enq( qu, w )
                    bvisited[ w ] = 1
                }
                pe = pe.next
            }
        }
        for i =1; i <= g.nvertices; i += 1{
            if bvisited[ i ] == 0 {
                connected = false
            }
        }
        return connected
    }
}

num_of_conn_comp :: proc (g : ^Graph_t ) {
    if g.directed == true {
        fmt.printf( "Don't forget to get the next version of the program :)" );
    } else {
        if is_connected( g ) {
            fmt.printf( "%v number of connected components.", g.nvertices )
        }
    }
}

