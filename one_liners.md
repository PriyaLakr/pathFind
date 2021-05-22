                                   
                                   =================== awk scripts to format blast output ===================

# 1
getting only good hits from blast output (fmt7); here column 4 is query coverage, you can add more filters

`awk '!/^\#/'  blast.out | awk -F "\t" '{ if ($4 >= 80) print $0}' > blast.out.goodhits`

`sort -k2 blast.out.goodhits > blast.out.goodhits.sorted`

# 2
comparing two different columns of two files, and if there is a match, create a new column!
useful in adding organism names and their genome length to blast output 

`awk 'FNR==NR{split($2,a,":"); split(a[2],b,"."); c=b[1]"."b[2]; d[c]=a[2]; split($3,f,":"); e[c]=f[2]; next}  { if (d[$2]) $13=d[$2]; $14=e[$2]}{print $0}' seqinfo.file blast.out.goodhits.sorted > blast.out.goodhits.sorted.ed`


