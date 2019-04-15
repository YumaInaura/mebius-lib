
#-----------------------------------------------------------
# 投稿後のスター - strict
#-----------------------------------------------------------
sub posted_get_star{

# 宣言
my($line,$title);

# 判定
if(rand(100) < 1){
$title="●メビリンスター出現（３）！　これを見つけたあなたには、きっと奇跡が起こるでしょう。";
$line = qq(<img src="/pct/star3.GIF" alt="メビリンスター">);
}

elsif(rand(10) < 1){
$title="●メビリンスター（２）出現！　あなたの運命は大上昇です。";
$line = qq(<img src="/pct/star2.GIF" alt="メビリンスター">);
}

else{
$title="●メビリンスター出現！　あなたに幸福が訪れますように。";
$line = qq(<img src="/pct/star1.GIF" alt="メビリンスター">);
}

return($line,$title);

}

1;
