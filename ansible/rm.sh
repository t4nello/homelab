#!/bin/bash

echo ">>> Zatrzymywanie wszystkich działających kontenerów..."
docker ps -q | xargs -r docker stop

echo ">>> Usuwanie wszystkich kontenerów..."
docker ps -a -q | xargs -r docker rm

echo ">>> Usuwanie wszystkich wolumenów..."
docker volume ls -q | xargs -r docker volume rm

# Jeśli chcesz usunąć również wszystkie obrazy (opcjonalne):
# echo ">>> Usuwanie wszystkich obrazów..."
# docker images -q | xargs -r docker rmi

echo ">>> Gotowe. Wszystkie kontenery i wolumeny zostały usunięte."
