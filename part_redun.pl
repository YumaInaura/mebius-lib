package main;

#-----------------------------------------------------------
# �A�����M�`�F�b�N
#-----------------------------------------------------------
sub do_redun{

# �Ǐ���
my($file,$block_second,$maxline,$routin) = @_;
my($type,$error_subroutin);
my($block_flag,$i,$next_time,$next_second,@line,$redun_handle);

# �G���[�T�u���[�`�����`
if($routin){ $error_subroutin = $routin; } else { $error_subroutin = "error"; }

# �t�@�C����`
if($file =~ /Not-error/){ $type .= qq( Get-only); }
if($file =~ /Get-only/){ $type .= qq( Get-only); }
$file =~ s/Not-error//g;
$file =~ s/Get-only//g;
$file =~ s/[^0-9a-zA-Z\-_]//g;
if($file eq ""){ return; }

# �ۑ�����s�����`
if(!$maxline){ $maxline = 50; }

# �A�����M���֎~����b
if($alocal_mode || $redun_flag eq "0"){ $block_second = 3; }

# �ǉ�����s
push(@line,"$time<>$date<>$addr<>$agent<>$cnumber<>$pmfile<>\n");

# �t�@�C�����J��
open($redun_handle,"${int_dir}_backup/_redun/${file}_redun.log");
	while(<$redun_handle>){
		chomp;
		my($lasttime,$date2,$addr2,$age2,$number2,$account2) = split(/<>/);
		my($flag);
			if($time < $lasttime + $block_second){
				if($addr2 && $addr2 eq $addr){ $flag = 1; }
				if($age2 && $age2 eq $agent && ($kaccess_one || $k_access)){ $flag = 2; }
				if($number2 && $number2 eq $cnumber){ $flag = 3; }
				if($account2 && $pmfile eq $account2){ $flag = 4; }
				if($flag){ $next_second = $lasttime + $block_second - $time; $block_flag = $flag; }
			}
		$i++;
		if($i < $maxline){ push(@line,"$_\n"); }
	}
close($redun_handle);

	# �c��b�����v�Z
	if($next_second){
		if($next_second >= 1*60){ $next_time = int($next_second/60)+1 . qq(��); }
		else{ $next_time = $next_second . qq(�b); }
	}

	# �f�[�^�擾�݂̂ŋA��ꍇ
	if($type =~ /Get-only/){ return($next_time); }

	# �G���[��\������
	if($block_flag){
		&$error_subroutin("�A�����M�͏o���܂���($block_flag)�B���� $next_time �قǊԊu�������đ��M���Ă��������B");
	}

# �t�@�C�����X�V
Mebius::Fileout("","${int_dir}_backup/_redun/${file}_redun.log",@line);

# ���^�[��
return($block_flag);

}

1;
