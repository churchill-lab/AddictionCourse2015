# JAX Systems Genetics Short Course

This is a directory for a workshop on JAX Short Course On The Genetics Of Addiction where we demonstrated [R/DOQTL], [kallisto] and [EMASE].

We created two docker images for this purpose: `simecek/addictioncourse2015` and `kbchoi/asesuite`. Docker is a lightweight container virtualization platform. You can run docker images on your computer or in the cloud like AWS, Microsoft Azure or Google Cloud. 

Here, I will show how to run them on [Digital Ocean](https://www.digitalocean.com/?refcode=673c97887267). To do that you can either start the machine manually, SSH to it and run the droplets. Or if you feel to be an advanced user, you can use [R/analogsea](https://github.com/sckott/analogsea) package to do that for you (linux only). 

In both cases, start with creating an account on [Digital Ocean](https://www.digitalocean.com/?refcode=673c97887267). You should get $10 promotional credit (= free 3.5 days for the 8BG machine).

## For beginners - start docklet manually

* Create a droplet (8GB memory, 4 CPU, $0.119/hour), in 'Select image', click on 'Applications tab' and select Docker
* SSH into your droplet and pull docker images
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
* SSH into your droplet and run docker images
```{r}
  docker run -d -v /sanger:/sanger -p 8787:8787 -e USER=rstudio -e PASSWORD=rstudio simecek/addictioncourse2015
  docker run -dt -v /sanger:/sanger -v /kbdata:/kbdata -p 8080:8080 kbchoi/asesuite
```
## For advanced users - use R/analogsea package

* install analogsea package to your computer
* create Digital Ocean API key and copy it into the script below
* run the following script

```
library("analogsea")
Sys.setenv(DO_PAT = "*** REPLACE BY YOUR DIGITAL OCEAN API KEY ***")

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

In both cases, see Digital Ocean droplets list to find IP of your machine. In your browser you can now access RStudio http://IP:8787 (user: rstudio, password: rstudio) and terminal http://IP:8080 (user: root, password: root).

You are paying for your Digital Ocean machine as long as it is running. Do not forget to destroy it in the end!

