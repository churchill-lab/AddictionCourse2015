# Short Course On The Genetics Of Addiction

This is a directory for a 2h bioinformatic workshop on [Short Course On The Genetics Of Addiction](https://www.jax.org/education-and-learning/education-calendar/2015/august/short-course-on-the-genetics-of-addiction) (August 27, 2015) at [The Jackson Laboratory](http://www.jax.org) that includes the following tutorials:

* __kallisto & EMASE__: generate and index, pseudoalign reads and quantify the expression [kallisto_emase_tutorial.sh](https://github.com/simecek/AddictionCourse2015/blob/master/scripts/kallisto_emase_tutorial.sh)
* __DOQTL__: kinship matrix, linkage and association mapping [addiction_DOQTL_tutorial.Rmd](https://github.com/simecek/AddictionCourse2015/blob/master/scripts/addiction_DOQTL_tutorial.Rmd) 
* __DESeq2__: detect differential expression between groups of RNASeq samples [DESeq2_tutorial.R](https://github.com/simecek/AddictionCourse2015/blob/master/scripts/DESeq2_tutorial.R) 

The participants use their web browsers to connect to customized [Docker](https://docs.docker.com/) containers hosted on [Digital Ocean](https://www.digitalocean.com/?refcode=673c97887267) virtual machines (see printscreens below).

![rstudio](figures/rstudio.jpg) | ![terminal](figures/butterfly.jpg)

Docker is a lightweight container virtualization platform. We created two Docker images for this course: [simecek/addictioncourse2015](https://github.com/simecek/AddictionCourse2015/blob/master/Dockerfile) (RStudio, DOQTL, DESeq2) and [kbchoi/asesuite](https://github.com/simecek/AddictionCourse2015/blob/master/Dockerfile_asesuite) (kallisto, EMASE).  You can run docker containers on your computer or in the cloud environments like AWS, Microsoft Azure or Google Cloud. [Dockerfile](https://github.com/simecek/AddictionCourse2015/blob/master/Dockerfile_asesuite) can be also used as a list of instructions how to install the software on your computer.

## How to start Digital Ocean docklet?

Here, I will give a description how our virtual machines have been created. You can either create the machine manually on Digital Ocean, SSH to it and start the docker containers. Or you can use [R/analogsea](https://github.com/sckott/analogsea) package to start a docklet from the command line. 

In both cases, you should start with creating an account on [Digital Ocean](https://www.digitalocean.com/?refcode=673c97887267). You should get $10 promotional credit (= free 3.5 days of the 8BG machine).

### For beginners - start docklet manually

* Log into Digital Ocean. Click on "Create Droplet" button. Choose any droplet hostname and select it size - 8GB memory, 4 CPU, $0.119/hour. Scroll down to "Select image"", click on 'Applications' tab and select Docker. Click on "Create Droplet" button. Docklet now starts (takes 1-2 minutes). You should receive an email with the password.
* Note down your docklet IP.ADDRESS. SSH into your droplet (`ssh root@IP.ADDRESS`) and pull docker images
```{r}
  docker pull rocker/hadleyverse
  docker pull simecek/addictioncourse2015
  docker pull kbchoi/asesuite
```
* SSH into your droplet and download data
```{r}
  mkdir -p /sanger;
  chmod --recursive 755 /sanger;
  wget --directory-prefix=/sanger ftp://ftp-mouse.sanger.ac.uk/REL-1505-SNPs_Indels/mgp.v5.merged.snps_all.dbSNP142.vcf.gz.tbi;
  wget --directory-prefix=/sanger ftp://ftp-mouse.sanger.ac.uk/REL-1505-SNPs_Indels/mgp.v5.merged.snps_all.dbSNP142.vcf.gz
  mkdir -p /kbdata;
  chmod --recursive 755 /kbdata;
  wget --directory-prefix=/kbdata ftp://ftp.jax.org/kb/individualized.transcriptome.fa.gz;
  wget --directory-prefix=/kbdata ftp://ftp.jax.org/kb/rawreads.fastq.gz
```
* SSH into your droplet and run docker containers. If you want to work with your own dataset, create a folder for it (like /mydata) and link it to the docker containers using `-v` option (`-v /mydata:/mydata`)
```{r}
  docker run -d -v /sanger:/sanger -p 8787:8787 -e USER=rstudio -e PASSWORD=rstudio simecek/addictioncourse2015
  docker run -dt -v /sanger:/sanger -v /kbdata:/kbdata -p 8080:8080 kbchoi/asesuite
```
### For advanced users - start docklet with R/analogsea package

* install [R/analogsea](https://github.com/sckott/analogsea) package to your computer
* create Digital Ocean API key and copy it to the second line of a script below
* run the script

```
library("analogsea")
Sys.setenv(DO_PAT = "*** REPLACE THIS BY YOUR DIGITAL OCEAN API KEY ***")

d <- docklet_create(size = getOption("do_size", "8gb"), 
                    region = getOption("do_region", "nyc2"))

# pull images
d %>% docklet_pull("rocker/hadleyverse")
d %>% docklet_pull("simecek/addictioncourse2015")
d %>% docklet_pull("kbchoi/asesuite")
d %>% docklet_images()

# download files from Sanger, takes ~30mins
lines <- "mkdir -p /sanger;
chmod --recursive 755 /sanger;
wget --directory-prefix=/sanger ftp://ftp-mouse.sanger.ac.uk/REL-1505-SNPs_Indels/mgp.v5.merged.snps_all.dbSNP142.vcf.gz.tbi;
wget --directory-prefix=/sanger ftp://ftp-mouse.sanger.ac.uk/REL-1505-SNPs_Indels/mgp.v5.merged.snps_all.dbSNP142.vcf.gz"
cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
analogsea:::do_system(d, cmd, verbose = TRUE)

# download KB's data files
lines <- "mkdir -p /kbdata;
chmod --recursive 755 /kbdata;
wget --directory-prefix=/kbdata ftp://ftp.jax.org/kb/individualized.transcriptome.fa.gz;
wget --directory-prefix=/kbdata ftp://ftp.jax.org/kb/rawreads.fastq.gz"
cmd <- paste0("ssh ", analogsea:::ssh_options(), " ", "root", "@", analogsea:::droplet_ip(d)," ", shQuote(lines))
analogsea:::do_system(d, cmd, verbose = TRUE)

# run dockers
d %>% docklet_run("-d", " -v /sanger:/sanger", " -p 8787:8787", " -e USER=rstudio", " -e PASSWORD=rstudio ", "simecek/addictioncourse2015") %>% docklet_ps()
d %>% docklet_run("-dt", " -v /sanger:/sanger -v /kbdata:/kbdata", " -p 8080:8080 ", "kbchoi/asesuite") %>% docklet_ps()

# kill droplet
# droplet_delete(d)
```

### Access your docklet - RStudio and terminal

In your browser you can now access RStudio on http://YOUR.IP.ADDRESS:8787 (user: rstudio, password: rstudio) and terminal http://YOUR.IP.ADDRESS:8080 (user: root, password: root).

You are paying for your Digital Ocean machine as long as it is running. Do not forget to destroy it at the end!

