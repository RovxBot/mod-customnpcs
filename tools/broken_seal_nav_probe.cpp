// Standalone native map-1 navigation verifier. Arguments: mmap directory, include flags (1 or 9).
#include "DetourAlloc.h"
#include "DetourNavMesh.h"
#include "DetourNavMeshQuery.h"
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <vector>

static std::vector<char> Read(std::filesystem::path const& path)
{
    std::ifstream file(path, std::ios::binary);
    return {std::istreambuf_iterator<char>(file), {}};
}
int main(int argc, char** argv)
{
    if (argc < 2 || argc > 3)
        return 1;
    auto parameters = Read(std::filesystem::path(argv[1]) / "001.mmap");
    if (parameters.size() != sizeof(dtNavMeshParams))
        return 2;
    dtNavMesh* mesh = dtAllocNavMesh();
    if (dtStatusFailed(mesh->init(reinterpret_cast<dtNavMeshParams*>(parameters.data()))))
        return 3;
    for (auto const& entry : std::filesystem::directory_iterator(argv[1]))
        if (entry.path().extension() == ".mmtile")
        {
            auto blob = Read(entry.path());
            unsigned size = 0;
            std::memcpy(&size, blob.data() + 12, 4);
            unsigned header = blob.size() - size;
            if (header != 56 && header != 20)
                return 4;
            auto* data = static_cast<unsigned char*>(dtAlloc(size, DT_ALLOC_PERM));
            std::memcpy(data, blob.data() + header, size);
            if (dtStatusFailed(mesh->addTile(data, size, DT_TILE_FREE_DATA, 0, nullptr)))
                return 5;
        }
    dtNavMeshQuery* query = dtAllocNavMeshQuery();
    if (dtStatusFailed(query->init(mesh, 8192)))
        return 6;
    dtQueryFilter filter;
    filter.setIncludeFlags(argc == 3 ? std::stoi(argv[2]) : 1);
    float extent[3] = {3, 12, 3};
    char mode;
    float x, y, z, endX, endY, endZ;
    while (std::cin >> mode >> x >> y >> z)
    {
        float start[3] = {y, z, x}, near[3];
        dtPolyRef first = 0;
        query->findNearestPoly(start, extent, &filter, &first, near);
        if (mode == 'p')
        {
            std::cout << first << ' ' << near[2] << ' ' << near[0] << ' ' << near[1] << '\n';
            continue;
        }
        std::cin >> endX >> endY >> endZ;
        float end[3] = {endY, endZ, endX}, endNear[3];
        dtPolyRef last = 0;
        query->findNearestPoly(end, extent, &filter, &last, endNear);
        dtPolyRef path[2048];
        int count = 0;
        dtStatus status = first && last ? query->findPath(first, last, near, endNear, &filter, path, &count, 2048) : DT_FAILURE;
        bool complete = !dtStatusFailed(status) && count && path[count - 1] == last;
        std::cout << complete << ' ' << count << ' ' << first << ' ' << last << '\n';
    }
    dtFreeNavMeshQuery(query);
    dtFreeNavMesh(mesh);
}
