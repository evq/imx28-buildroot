# Linux Target Image Builder (LTIB) Buildroot for i.MX28

Mostly sewn together from the instructions available [on the freescale community docs.](https://community.freescale.com/docs/DOC-98910)

## Instructions for use

This doesn't distribute the freescale sources, download [L2.6.35_1.1.0_130130_source.tar.gz from freescale.](http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=IMX28_SW) It is available under Linux -> Linux Source Code Files. Download requires one to make an account and login.

After downloading, place in this directory and run:

docker build -t imx28 .

One can change defconfig before build to their liking.
