# User specific aliases and functions
alias hm='cd /home/muchenli/projects/def-lsigal/muchenli'
alias sq='squeue -u muchenli -o "%.18i %.9P %.35j %.8u %.8T %.10M %.9l %.6D %R"'
alias sqp='squeue -o "%.18i %.9P %.35j %.8u %.8T %.10M %.9l %.6D %R"'

mkdir -p ~/trash_can
function filter_txts(){
    limit=${2:-300} find $1 -type f -readable -exec sh -c '
    for file do
      lines=$(head -1000 "$file" | wc -l) && [ "$((lines))" -lt $limit ] && echo "$file"
    done' sh {} +
}

function filter_and_del_txts(){
    limit=${2:-300} find $1 -type f -readable -exec sh -c '
    for file do
      lines=$(head -1000 "$file" | wc -l) && [ "$((lines))" -lt $limit ] && mv "$file" ~/trash_can
    done' sh {} +
}


alias f_txt="filter_txts"
alias fd_txt="filter_and_del_txts"
