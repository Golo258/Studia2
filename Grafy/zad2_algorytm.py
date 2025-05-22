import heapq

graph = {
    'A': [('D', 2), ('M', 9), ('W', 3)],
    'D': [('A', 2), ('M', 2), ('G', 3)],
    'G': [('D', 3), ('J', 5), ('N', 1)],
    'J': [('G', 5), ('P', 4), ('K', 4)],
    'K': [('J', 4), ('S', 2), ('L', 2)],
    'L': [('K', 2)],
    'M': [('A', 9), ('D', 2), ('G', 1), ('N', 2), ('W', 1)],
    'N': [('M', 2), ('G', 1), ('P', 9), ('J', 7)],
    'P': [('N', 9), ('J', 4), ('S', 3)],
    'S': [('P', 3), ('K', 2), ('L', 6)],
    'W': [('M', 4), ('N', 9), ('Z', 7)],
    'Z': [('P', 5), ('S', 4), ('W', 7)],
}
s
start = 'G'

distances = {node: float('inf') for node in graph}
previous = {node: None for node in graph}
distances[start] = 0

queue = [(0, start)]

while queue:
    current_dist, current_node = heapq.heappop(queue)
    
    if current_dist > distances[current_node]:
        continue

    for neighbor, weight in graph[current_node]:
        distance = current_dist + weight
        if distance < distances[neighbor]:
            distances[neighbor] = distance
            previous[neighbor] = current_node
            heapq.heappush(queue, (distance, neighbor))

print(f"Shortest paths from node {start}:\n")
for node in sorted(graph.keys()):
    path = []
    current = node
    while current is not None:
        path.insert(0, current)
        current = previous[current]
    if distances[node] < float('inf'):
        print(f"{start} -> {node} | cost: {distances[node]} | path: {' -> '.join(path)}")
    else:
        print(f"{start} -> {node} | no path")
