
package main;

#-----------------------------------------------------------
# 掲示板のインデックスをバックアップ
#-----------------------------------------------------------
sub bbs_index_backup{

# 宣言
my($line,$i,$INDEX_IN);
our($nowfile,$moto);

# エラー処理
if($nowfile eq ""){ return(); }

# 現行インデックスを開く
open($INDEX_IN,"<$nowfile");
	while(<$INDEX_IN>){
		$i++;
		$line .= $_;
	}
close($INDEX_IN,"$nowfile");

	# 現行インデックスをバックアップ
	if($i >= 5){
		Mebius::Fileout(undef,"${int_dir}_backindex/${moto}_idx.log",$line);
	}


}

1;
