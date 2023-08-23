# Graph in Odin

<strong>This is a code of a port of graph originally implemented in C to Odin. Adjacency lists have been used to make the graph.</strong> <br>
There is a good section on templates in the queue.odin file, several different template ways of doing the same thing, it was the fruit of a really good discussion with the discord members of the Odin forum, my thanks go to them.

## Original C code for this port to Odin
Original source code in C can be found at:

```
Github tharaka27 / graph-c
       Tharaka Ratnayake 
       https://github.com/tharaka27/graph-c
```


## How to use this graph ?

First of all yo have to allocate memory for the graph. which you can do with following.

``` odin
my_g1, my_g2 : ^Graph_t
my_g1 = nil
my_g2 = nil 
if len( os.args ) < 2 {
    fmt.eprintf( "Usage: %v graph_name" , args[0] )
    os.exit( -1 )
}
my_g1 = new( Graph_t )
defer free( my_g1 )

```
They you can use following method to implement the graph as you wish.


### 1. Initialize the graph.
This will initialize the graph. There are two parameters which you should pass.
One is the graph *my_g1* second is the directionality of the graph.
*true* if directed *false* if undirected.
```Odin
initialize_graph :: proc ( g: ^Graph_t, directed: bool )
```
Example :
``` odin
initialize_graph( my_g1, false )
```


### 2.Read the graph.
This will read the graph from given file. We have added an example file so you can have a
idea about how data should be presented in graph
``` odin
read_graph :: proc (g : ^Graph_t, filename : string)
```
Example :
```odin
read_graph( myg1, os.args[1] )
```


### 3. Insert an edge.
This will insert an edge with weight *w* to graph g from *x* to *y*. 
``` odin
insert_edge :: proc ( g : ^Graph_t, x : int, y : int, w : int )
```
Example :
``` odin
insert_edge( my_g1, 1, 2, 10 )
```


### 4. Delete an edge.
This will delete the edge of graph 
``` odin
delete_edge :: proc ( g : ^Graph_t, from : int , to : int )
```
Example :
``` odin
delete_edge( my_g1, 1, 2 )
```


### 5. Print graph.
This function can be used to print the graph. Name of the graph should be *name*
``` odin
print_graph :: proc (g : ^Graph_t , name : string )
```
Example :
``` odin
print_graph( my_g1, "my_g1")
```


### 6. Print degree.
This function will print the degree of the given graph
``` odin
print_degree :: proc (g : ^Graph_t )
```
Example :
``` odin
print_degree( my_g1 )
```


### 7. Print Complement.
This function will print the compliment grpah of given grpah. set the k value for 1. 
``` odin
print_complement :: proc (g : ^Graph_t, p : int )
```
Example :
``` odin
print_complement( my_g1, 1 )
```


### 8. Eliminate links.
This function will eliminate the links which have a weight less than *minW* or more than *maxW*
``` odin
eliminate_links :: proc (g : ^Graph_t , minW : int, maxW : int )
```
Example :
``` odin
eliminate_links(my_g1, 2, 5 )
```


### 9. Different Links.
This will find the different links between graph *g* and *c*. graph *g* will be given priority
so this will print the links of *g* which are not in *c*
``` odin
different_links :: proc (g : ^Graph_t , c : ^Graph_t )
```
Example :
``` odin
different_links( my_g1, my_g2 )
```


### 10. Common Links.
This will find and print the common links of graph *g* and graph *c*
``` odin
common_links :: proc (g : ^Graph_t , c : ^Graph_t )
```
Example :
``` odin
common_links( my_g2, my_ g1 )
```


### 11. Depth First Search.
This function will perform the Depth First Search starting from node *k*
``` odin
dfs :: proc ( g : ^Graph_t, k : int )
```
Example :
``` odin
dfs( my_g1, 1 )
```


### 12. Breadth First Search.
This function will perform the Breadth First Search starting from node *k*
``` odin
bfs :: proc ( g : ^Graph_t, k : int )
```
Example :
``` odin
bfs( my_g1, 1 )
```


### 13. Check the connectivity of a graph.
This will return *True* if the graph is connected of *False* if not
``` odin
is_connected :: proc ( g : ^Graph_t ) -> bool
```
Example :
``` odin
connected : bool = is_connected( my_g1 )
```


### 13. Check the number of connected components.
This will print the number of connected components in the graph
``` odin
num_of_conn_comp :: proc (g : ^Graph_t )
```
Example :
``` odin
num_of_conn_comp( my_g1 )
```


### 13. Copy a graph.
This will copy the give graph and will return the pointer to the newly created graph 
``` odin
copy_graph :: proc (g : Graph_t) -> ^Graph_t
```
Example :
``` odin
my_g2 = copy_graph( my_g1 )
```


### 14. free a graph.
Free's the memory used by the graph.
``` odin
free_graph :: proc ( g : ^Graph_t )
```
Example :
``` odin
free_graph( my_g1 )
```

## Best regards,
Joao Carvalho