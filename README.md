# WSEI DevOps - Aplikacja Nuxt.js + MySQL

Projekt na studia z przedmiotu DevOps

- _Autor_: **Marcin Włodyka**
- _Indeks_: **13860**

## Cel i opis projektu

### Cel projekty

Celem projektu jest dodanie konteneryzacji i budowania do prostej aplikacji Nuxt.js i server'a bazodanowego MySQL. Aplikacja Nuxt.js powinna móc się połączyć z server'em MySQL aby wykonywać operacje na bazie danych.

### Opis projektu

Projekt to prosta aplikacja zawierający prosty backend i interfejs użytkownika, stworzone przy użyciu Nuxt.js i MySQL.

Aplikacja służy do zapisywania prostych wiadomości tekstowych w bazie danych i wyświetlania ich na stronie w przeglądarce.

W aplikacji Nuxt.js na backend'zie jest stworzony endpoint `/api/messages`, z metodami `POST` i `GET` wykonujące operacje na bazie danych MySQL:

- `GET` - pobiera rekordy z tablicy `messages` i zwraca je w formie tablicy JSON o typie `Message`

```ts
interface Message {
  id: number;
  message: string;
}
```

- `POST` - dodaje nowy rekord do tablicy `messages`

Część frontend'owa tej aplikacji to prost strona HTML. Strona zawiera formularz z polem tekstowym do wysyłania wiadomości i prostą liste wszystkich dodanych wiadomości.

![alt text](/docs/frontend.png)

## Komendy Linux'owe

- `cd` - przejście do wybranego katalogu za pomocą jego ścieżki
- `ls` - służy do wyświetlenia zawartości katalogu w którym się znajdujemy lub katalogu z podanej ścieżki, dodatkowo informacje o plikach w katalogu w zależności od podanych flag np. permisji danego pliku
- `mkdir` - stworzenie nowego katalogu
- `touch` - stworzenie pustego pliku
- `vim` - edytor tekstowy z którego trudno wyjść
- `chmod` - zmiana permisji katalogu lub pliku
- `chown` - zmiana właściciela katalogu lub pliku
- `apt` - służy do instalowania lub aktualizowania aplikacji i systemu

## Git/GitHub

1. GitHub repo link: https://github.com/marcinwlodyka/wsei-devops

2. Komendy git:

- `git init` - zainicjowanie repozytorium
- `git branch <name>` - create a new branch
- `git add -A` - dodanie wszystkich zmian na stage
- `git commit -m <message>` - dodanie commit'a z wiadomością
- `git remote add origin <url>` - dodanie remote'a do repozytorium
- `git push -u origin <branch>` - wypchnięcie nowego branch'a na remote'a

3. Dodawanie kluczu ssh

- Wygenerowanie klucza ssh komendą `ssh-keygen -t ed25519 -C "your_email@example.com"`
- Dodanie klucza do agenta ssh
  - Uruchomienie agenta w tle `eval "$(ssh-agent -s)"`
  - Dodanie klucza `ssh-add ~/.ssh/id_ed25519`
- Skopiowanie zawartości komedy `cat ~/.ssh/id_ed25519.pub`
- Na GitHub'bie w prawym górnym rogu kliknięcie na avatar > `Settings` > `SSH and GPG keys` > `New SSH key`, wpisanie w tytułu w polu `title` i wklejenie klucza do pola `key`

4. **Po co wykorzystujemy klucze ssh?** Używamy kluczu ssh aby połączyć się z naszym kontem GitHub i móc odczytywac i zapisywać dane na nim.

## Docker

1. **Konteneryzacja** pozwala nam uruchomić naszą aplikację i jej składowe w osobnych środowiskach. Dzięki konteneryzacji nasza aplikacja może zostać uruchomiona na wielu systemach nie zależnie od systemu operacyjnego czy innych zmiennych środowiska. Po przez wyżej wymienione cechy konteneryzacja wspomaga naszą skalowalność i pomaga zespołom developerów w pracy nad tym samym projektem na różnych maszynach.

2. `dockerfile`

```dockerfile
# Użycie obrazu z runtime'm Node'a dla naszej aplikacji zbudowanej w JavaScript/TypeScript
FROM node:18 AS build

# Ustawienie aktywnego katalogu
WORKDIR /app

# Skopiowanie plików package.json i package-lock.json zawierających listę zależności naszego projektu
COPY package*.json ./

# Instalacja zależności naszego projektu
RUN npm install

# Przekopiowanie reszty projektu/kodu
COPY . .

# Zbudowanie aplikacji Nuxt.js
RUN npm run build

# Stworzenie obrazu produkcyjnego z server'em
FROM node:18-alpine

# Ustawienie aktywnego katalogu
WORKDIR /app

# Skopiowanie plików build'u
COPY --from=build /app ./

# Instalacja wyłącznie produkcyjnych zależności
RUN npm install --production

# Wystawienie port'u HTTP
EXPOSE 3000

# Uruchomienie server'u Nuxt.js po przez npm
CMD ["npm", "start"]
```

## Docker compose

1. **Docker compose** pozwala nam definiować i uruchamiać wielokontenerowe aplikację, co jest przydatne w zażądaniu zależnościami między różnymi segmentami naszej aplikacji np.: server'em bazodanowym, naszym backend'em czy klientem frontend'owym

```yaml
version: '3'
services:
  # Konfiguracja serwisu bazy danych
  mysql-db:
    # Używamy naszego obrazu z MySQL'em
    image: mysql:8.0
    container_name: mysql-db
    # Ustawienie zmiennych środowiskowych
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=mydb
    # Port na jakim server MySQL zostanie uruchomiony
    ports:
      - '3306:3306'
    networks:
      - my-network
    # Mapowanie volume'ów które pozostaną między uruchomieniami
    volumes:
      - mysql-data:/var/lib/mysql
      # Skrypt tworzący bazę danych i tabele `messages`
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql

  # Konfiguracja naszej aplikacji
  nuxt-app:
    build: .
    # Nazwa kontenera naszej aplikacji
    container_name: nuxt-app
    # Port na którym zostanie uruchomiona aplikacja
    ports:
      - '3000:3000'
    # Dodanie zależności do naszego server'u MySQL
    depends_on:
      - mysql-db
    networks:
      - my-network
    # Zmienne środowiskowe potrzebne do połączenia z server'em MySQL
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql-db
      - DB_PORT=3306
      - DB_NAME=mydb
      - DB_USER=root
      - DB_PASSWORD=rootpassword

networks:
  my-network:

volumes:
  mysql-data:
```

# Continuous integration

**CI _(Continuous Integration)_** to praktyka w tworzeniu oprogramowania, polegająca na regularnym i automatycznym integrowaniu zmian w kodzie z główną gałęzią projektu. Każda zmiana jest automatycznie budowana i testowana, co pozwala szybko wykrywać i naprawiać błędy, utrzymując wysoką jakość kodu.

**Workflow** utworzone w tym projekcie wykonuję się na każdy push na branch mai. Akcja zaczyna się od zainstalowania i cache'owania zależności, aby przyszłe akcje wykonywały się szybciej. Następnie buduję naszą aplikację na 3 wersjach Node.js (18, 20, 22), aby sprawdzić czy nasza aplikacja działa.

## Kubernetes

### Opis Kubernetes

Kubernetes to platforma do zarządzania kontenerami, która automatyzuje wdrażanie, skalowanie i operacje aplikacji kontenerowych. Dzięki Kubernete'sowi można łatwo zarządzać złożonymi aplikacjami składającymi się z wielu kontenerów, zapewniając wysoką dostępność, skalowalność i łatwość w zarządzaniu. Kubernetes umożliwia automatyczne przydzielanie zasobów, monitorowanie stanu aplikacji oraz automatyczne naprawianie problemów, co znacząco ułatwia zarządzanie aplikacjami w środowiskach produkcyjnych.

### Pliki deployment

#### `nuxt-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nuxt-app
spec:
  selector:
    matchLabels:
      app: nuxt-app
  replicas: 3
  template:
    metadata:
      labels:
        app: nuxt-app
    spec:
      containers:
        - name: nuxt-app
          image: your-node-nuxt-image
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: 'production'
            - name: DB_HOST
              value: 'mysql-service'
            - name: DB_PORT
              value: '3306'
            - name: DB_NAME
              value: 'mydb'
            - name: DB_USER
              value: 'root'
            - name: DB_PASSWORD
              value: 'rootpassword'
---
apiVersion: v1
kind: Service
metadata:
  name: nuxt-service
spec:
  ports:
    - port: 3000
      targetPort: 3000
  selector:
    app: nuxt-app
  type: NodePort
```

1. Deployment `nuxt-app`:

- apiVersion: Wersja API Kubernetes.
- kind: Typ zasobu, w tym przypadku Deployment.
- metadata: Metadane, takie jak nazwa zasobu.
- spec: Specyfikacja Deploymentu, w tym selektor, liczba replik i szablon podów.
- containers: Definicja kontenera, w tym obraz, porty i zmienne środowiskowe.

2. Service `nuxt-service`:

- apiVersion: Wersja API Kubernetes.
- kind: Typ zasobu, w tym przypadku Service.
- metadata: Metadane, takie jak nazwa zasobu.
- spec: Specyfikacja serwisu, w tym porty i selektor.

#### `mysql-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-db
spec:
  selector:
    matchLabels:
      app: mysql-db
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql-db
    spec:
      containers:
        - name: mysql-db
          image: mysql:8.0
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: 'rootpassword'
            - name: MYSQL_DATABASE
              value: 'mydb'
          ports:
            - containerPort: 3306
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: mysql-storage
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: mysql-pv-claim
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  ports:
    - port: 3306
      targetPort: 3306
  selector:
    app: mysql-db
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

1. Deployment mysql-db:

- apiVersion: Wersja API Kubernetes.
- kind: Typ zasobu, w tym przypadku Deployment.
- metadata: Metadane, takie jak nazwa zasobu.
- spec: Specyfikacja Deploymentu, w tym selektor, liczba replik i szablon podów.
- containers: Definicja kontenera, w tym obraz, porty,
- zmienne środowiskowe i montowanie woluminów.

2. Service mysql-service:

- apiVersion: Wersja API Kubernetes.
- kind: Typ zasobu, w tym przypadku Service.
- metadata: Metadane, takie jak nazwa zasobu.
- spec: Specyfikacja serwisu, w tym porty i selektor.

3. PersistentVolumeClaim mysql-pv-claim:

- apiVersion: Wersja API Kubernetes.
- kind: Typ zasobu, w tym przypadku PersistentVolumeClaim.
- metadata: Metadane, takie jak nazwa zasobu.
- spec: Specyfikacja woluminu, w tym tryb dostępu i zasoby.
