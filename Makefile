all:
	odin build . -out:./graph -debug

clean:
	rm ./graph

run:
	./graph undirected_graph1.txt
