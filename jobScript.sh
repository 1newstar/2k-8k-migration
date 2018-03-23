for ((i in `seq 1 24`))
{ 
 if [$i -lt 7]; then
   echo "I am less than seven: "$i
 else
   echo "I am greater than seven: "$i  
  fi
}
