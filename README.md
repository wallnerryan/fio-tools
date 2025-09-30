# FIO-Tools

![Alt text](http://i.imgur.com/3oFD3XP.png "Plot Example")
![Alt text](http://i.imgur.com/5vUItaO.png "Plot Example")

## How to use this repo

1. Build the images or use the public images
2. Create a [Fio Jobfile](https://media.readthedocs.org/pdf/fio/latest/fio.pdf)
3. Run the `fio-tool` image

  ```
  docker run -v /tmp/fio-data:/tmp/fio-data \
  -e JOBFILES=<your-fio-jobfile> \
  wallnerryan/fio-tool
  ```
If your file is a remote raw text file, you can use REMOTEFILES 

  ```
  docker run -v /tmp/fio-data:/tmp/fio-data \
  -e REMOTEFILES="http://url.com/<your-job>.fio" \
  -e JOBFILES=<your-fio-jobfile> wallnerryan/fio-tool
  ```
4. Run the `fio-genplots` script

  ```
  docker run -v /tmp/fio-data:/tmp/fio-data wallnerryan/fio-genplots
  ```
5. Serve your Graph Images and Log Files

  ```
  docker run -p 8000:8000 -d -v /tmp/fio-data:/tmp/fio-data \
  wallnerryan/fio-plotserve
  ```
6. *Easiest Way*, run the "all in one" image. (Will auto produce IOPS and BW graphs and serve them)

  ```
  docker run -p 8000:8000 -v /tmp/fio-data \
  -e REMOTEFILES="http://url.com/<your-job>.fio" \
  -e JOBFILES=<your-fio-jobfile> \
  -e PLOTNAME=MyTest \
  -d --name MyFioTest wallnerryan/fiotools-aio
  ```

### Other Examples

#### To use with Kubernetes

Use a `Deployment`

```
kubectl apply -f kubernetes/fiotools-aio-portworx-read.yaml
storageclass.storage.k8s.io "fio-tester-class-read" created
persistentvolumeclaim "fio-data-read" created
deployment.extensions "fio-tester-read" created
service "fiotools-read" created

kubectl apply -f kubernetes/fiotools-aio-portworx-write.yaml
storageclass.storage.k8s.io "fio-tester-class-write" created
persistentvolumeclaim "fio-data-write" created
deployment.extensions "fio-tester-write" created
service "fiotools-write" created

kubectl get svc fiotools-read
kubectl get svc fiotools-write
```

Access the Output

`kubectl port-forward service/fiotools-read  8001:8001`
Visit http://localhost:8001

`kubectl port-forward service/fiotools-write  8000:8000`
Visit http://localhost:8000

OR

Visit http://<Node-IP>:[8000|8001] as long as the firewall allows `8000 and 8001` to the workers.


> Note, you can change the `ENV` variables to submit a new job. Just provide a new job url to `REMOTEFILES` and update the name of `JOBFILES` to the name of the `.fio` file and provide and optional new `PLOTNAME`

```
env:
  - name: REMOTEFILES
    value: "https://gist.githubusercontent.com/wallnerryan/06cb07d3d8bee67af025a60a88da053f/raw/a46d97f30b79c2a2a6b42333e7114d85e84c450f/editablejob.fio"
  - name: JOBFILES
    value: editablejob.fio
  - name: PLOTNAME
    value: editablejob
```

##### *Important*
- *Your FIO `JOBFILES` should reference a `directory=/my/mounted/volume" to test against docker volumes
- *If you want to run more than one all-in-one job, just use `-v /tmp/fio-data` instead of `-v /tmp/fio-data:/tmp/fio-data` This is only needed when you run the individual tool images seperately 

##### To use with docker and docker volumes 
```
docker run \
-p 8000:8000 \
-v /tmp/fio-data \
-e REMOTEFILES="https://gist.githubusercontent.com/wallnerryan/6bcfec794cbaef9a86569d5553b156b3/raw/8a6f5a6cb924f493a095b5077ed402d71a333b52/realworld.fio" \
-e JOBFILES=realworld.fio \
-e PLOTNAME=MyTest \
-v myvol1:/myvol \
-d \
--name MyTest wallnerryan/fiotools-aio
```

To produce graphs, run the genplots container

*Produce IOPS/Bandwidth Graphs*
```
docker run -v /tmp/fio-data:/tmp/fio-data wallnerryan/fio-genplots 
```

Simply serve them on port 8000
```
docker run -p 8000:8000 -d \
-v /tmp/fio-data:/tmp/fio-data \
wallnerryan/fio-plotserve
```

*To use the all-in-one image*
```
docker run \
-p 8000:8000 \
-v /tmp/fio-data \
-e REMOTEFILES="https://gist.githubusercontent.com/wallnerryan/fd0146ee3122278d7b5f/raw/006ff707bc1a4aae570b33f4f4cd7729f7d88f43/job.fio" \
-e JOBFILES=job.fio \
-e PLOTNAME=MyTest \
—volume-driver flocker \
-v myvol1:/myvol \
-d \
—name MyTest wallnerryan/fiotools-aio
```

##### To use with docker-machine/boot2docker

You can use a remote fit configuration file using the REMOTEFILES env variable.
```
docker run \
-e REMOTEFILES="https://gist.githubusercontent.com/wallnerryan/fd0146ee3122278d7b5f/raw/d089b6321746fe2928ce3f89fe64b437d1f669df/job.fio" \
-e JOBFILES=job.fio \
-v /Users/wallnerryan/Desktop/fio:/tmp/fio-data \
wallnerryan/fio-tool
```

(or)

If you have a directory that already has them in it
```
docker run -v /Users/wallnerryan/Desktop/fio:/tmp/fio-data \
-e JOBFILES=job.fio fiotools/fio-tool
```

To produce graphs, run the genplots container
```
docker run \
-v /Users/wallnerryan/Desktop/fio:/tmp/fio-data wallnerryan/fio-genplots 
```

Simply serve them on port 8000
```
docker run -v /Users/wallnerryan/Desktop/fio:/tmp/fio-data \
-d -p 8000:8000 wallnerryan/fio-plotserve
```

#####  To use with docker that is *not* boot2docker or docker-machine , /tmp/fio-data is a still a VOLUME

You can use a remote configuration script
```
docker run \
-e REMOTEFILES="https://gist.githubusercontent.com/wallnerryan/fd0146ee3122278d7b5f/raw/2eb7d0ae9b77fa5a93662fe8088df2d83fff9ab2/job.fio" \
-v /tmp/fio-data:/tmp/fio-data \
-e JOBFILES=job.fio wallnerryan/fio-tool
```
(or)

You can create a directory and put it locally on the server where the container will run
```
mkdir /tmp/fio-data
cp <your FIO job file> /tmp/fio-data/
docker run -v /tmp/fio-data:/tmp/fio-data \
-e JOBFILES=<your FIO job> wallnerryan/fio-tool
```

To produce graphs, run the genplots container
```
docker run -v /tmp/fio-data:/tmp/fio-data wallnerryan/fio-genplots 
```

Simply serve them on port 8000
```
docker run -p 8000:8000 -d \
wallnerryan/fio-plotserve
```

###### Notes

- The fio-tools container will clean up the /tmp/fio-data volume by default when you re-run it. If you want to save any data, copy this data out or save the files locally.
- When you serve on port 8000, you will have a list of all logs created and plots created, click on the `.png` files to see graph (see below for example screen)


![Alt text](http://i.imgur.com/nksQkZi.png "Served Files")

**bw= and BW= explained**
 - https://www.spinics.net/lists/fio/msg05517.html 


## Build

This repo ships a single orchestrator script, `buildimages.sh`, that builds all the fio-tools images in the correct order, either **locally** (single-arch) or as a **multi-arch** build with a **push to Docker Hub**.

It solves common pitfalls like:
- child images failing with `FROM ${BASE_IMAGE}` because the base isn’t visible to BuildKit
- builder/context confusion on Docker Desktop
- reliably wiring build args (gnuplot/python versions) through the whole stack

---

## What it builds

The script builds these images (in order):

1. `base-fiotools`  → foundation image (gnuplot built from source, Python tuned, etc.)
2. `fio-genplots`   → plotting helper
3. `fio-tool`       → runner
4. `fio-plotserve`  → plot web server
5. `fiotools-aio`   → all-in-one image

All dependent Dockerfiles use:

```dockerfile
# syntax=docker/dockerfile:1.6
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
```

The script passes `--build-arg BASE_IMAGE=<tag>` so each layer builds against the **just-built base** (local mode) or the **just-pushed base** (push mode).

---

## Prerequisites

- Docker Desktop or Docker Engine 24+ (with `docker buildx` bundled)
- (For multi-arch) QEMU emulation: the script sets it up automatically with `tonistiigi/binfmt`
- (For push) Docker Hub login: `docker login`

---

## Modes

### 1) Local build (default)
- `FIOTOOLS_DOCKERHUB_PUSH=false` (or unset)
- Uses **classic `docker build`** so `FROM ${BASE_IMAGE}` resolves to the **local** tag you just built.
- **Single-arch only**: `PLATFORMS` **must match the host** (e.g. `linux/amd64` on Intel, `linux/arm64` on Apple Silicon).

### 2) Multi-arch + push
- `FIOTOOLS_DOCKERHUB_PUSH=true`
- Uses **buildx** with a **container driver**, builds **multi-arch** and **pushes** to Docker Hub.
- Base is pushed first; dependents then **pull** that base by tag.

---

## Environment variables

| Var | Default | Purpose |
|---|---|---|
| `FIOTOOLS_DOCKERHUB_USERNAME` | `fiotools` | Docker Hub namespace/repo prefix |
| `FIOTOOLS_DOCKERHUB_TAG` | `tag` | Tag applied to all images |
| `FIOTOOLS_DOCKERHUB_PUSH` | `false` | `true` = multi-arch buildx build + push |
| `PLATFORMS` | `linux/amd64,linux/arm64` | Target platforms (push mode). In local mode, **must equal host**. |
| `DOCKER_CONTEXT` | `default` | Docker context used by the script |
| `GNUPLOT_VERSION` | `5.4.10` | Built from source in `base-fiotools` |
| `PY_VER` | `3.12.5` | CPython version compiled in `base-fiotools` |

---

## Usage

### Local single-arch (build into your daemon)
```bash
# Pick the platform that matches your host CPU
export PLATFORMS=linux/amd64        # on Intel/Linux/Windows
# or
export PLATFORMS=linux/arm64        # on Apple Silicon

export FIOTOOLS_DOCKERHUB_USERNAME=<insert>
export FIOTOOLS_DOCKERHUB_TAG=<tag>
export FIOTOOLS_DOCKERHUB_PUSH=false

./buildimages.sh
```

You’ll end up with locally available images like:
```
wallnerryan/base-fiotools:fio336alpinev2
wallnerryan/fio-genplots:fio336alpinev2
wallnerryan/fio-tool:fio336alpinev2
wallnerryan/fio-plotserve:fio336alpinev2
wallnerryan/fiotools-aio:fio336alpinev2
```

### Multi-arch push (amd64 + arm64)
```bash
export FIOTOOLS_DOCKERHUB_USERNAME=<user>
export FIOTOOLS_DOCKERHUB_TAG=<tag>
export FIOTOOLS_DOCKERHUB_PUSH=true
export PLATFORMS=linux/amd64,linux/arm64

docker login
./buildimages.sh
```

This will:
1) build & **push** `wallnerryan/base-fiotools:fio336alpinev2` for both arches  
2) build & **push** the remaining images using that base

---

## Customizing versions

Override at runtime:

```bash
export GNUPLOT_VERSION=5.4.11
export PY_VER=3.12.7
./buildimages.sh
```

Both values are passed as `--build-arg`s into `base-fiotools`.

---

## Common pitfalls & fixes

- **“not found … base-fiotools:TAG” during dependent build**  
  You ran a buildx containerized build that can’t see your local daemon image.  
  ✅ Use local mode (default) → script runs **classic `docker build`** for all images, or  
  ✅ Use push mode so dependents **pull** the base from the registry.

- **“additional instances of driver ‘docker’ cannot be created”**  
  Old builders/contexts cause conflicts. The script avoids these, but if you hit leftovers:
  ```bash
  docker buildx ls
  docker buildx rm <stale-builder-name>
  docker context use default
  ```

- **“use \`docker context use default\`”**  
  You’re on a non-default context. Either:
  ```bash
  docker context use default
  ```
  or set `DOCKER_CONTEXT`:
  ```bash
  export DOCKER_CONTEXT=default
  ./buildimages.sh
  ```

- **Local mode with mismatched PLATFORMS**  
  Local `--load` can only load the host’s architecture. Set:
  ```bash
  export PLATFORMS=$(uname -m | grep -qi arm && echo linux/arm64 || echo linux/amd64)
  ```

---

## What changed vs. naive buildx flows?

- Local builds use **classic `docker build`** so your `FROM ${BASE_IMAGE}` can reference the **locally built tag**.
- Multi-arch builds use a **single containerized builder** that can **push**, ensuring dependents can pull the just-pushed base.

---

## Outputs & naming

All images are tagged as:
```
<NS>/<component>:<TAG>
```
Where `<NS>` = `FIOTOOLS_DOCKERHUB_USERNAME`, `<TAG>` = `FIOTOOLS_DOCKERHUB_TAG`.

---

## Clean up

To remove the buildx builder created by push mode (optional):
```bash
docker buildx rm fiotools || true
```

To reset contexts:
```bash
docker context use default
```

#### Force a clean rebuild (no cache) locally:

`NO_CACHE=1 ./buildimages.sh`


Also force parent pulls (ignore base-layer cache):

`NO_CACHE=1 PULL_BASE=1 ./buildimages.sh`


Multi-arch push with no cache:

`FIOTOOLS_DOCKERHUB_PUSH=true NO_CACHE=true PULL_BASE=true ./buildimages.sh`

Optional: completely nuke buildx caches

If you want to also wipe any persisted builder caches:

`docker --context "$DOCKER_CONTEXT" buildx prune -af`

---

## Security notes

- `base-fiotools` builds **gnuplot from source** and compiles **CPython** so you can avoid CVEs seen in Alpine’s prebuilt stacks.
- You can bump `GNUPLOT_VERSION` and `PY_VER` to pick up upstream fixes quickly.
- Downstream images inherit from the base—so security improvements are centralized.
