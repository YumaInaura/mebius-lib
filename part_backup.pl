
package main;

#-----------------------------------------------------------
# �f���̃C���f�b�N�X���o�b�N�A�b�v
#-----------------------------------------------------------
sub bbs_index_backup{

# �錾
my($line,$i,$INDEX_IN);
our($nowfile,$moto);

# �G���[����
if($nowfile eq ""){ return(); }

# ���s�C���f�b�N�X���J��
open($INDEX_IN,"<$nowfile");
	while(<$INDEX_IN>){
		$i++;
		$line .= $_;
	}
close($INDEX_IN,"$nowfile");

	# ���s�C���f�b�N�X���o�b�N�A�b�v
	if($i >= 5){
		Mebius::Fileout(undef,"${int_dir}_backindex/${moto}_idx.log",$line);
	}


}

1;
