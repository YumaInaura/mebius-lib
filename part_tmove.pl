
package main;

#-----------------------------------------------------------
# �ƂȂ�̋L���ֈړ�
#-----------------------------------------------------------

sub bbs_tmove{

# �Ǐ���
my($i,$file,$no,$flag);

# �t�@�C����`
$file = $in{'no'};
$file =~ s/\D//;
if($file eq ""){ &error("�L�����w�肵�Ă��������B"); }

# �N��
my($Age);
if(!$cage){ $Age = 0; }
else{ $Age = $thisyear - $cage; }

	# �J��Ԃ�����
	for(1..15){
		$i++;

		if($in{'next'}){ $file++; } else { $file--; }
		if($file < 0){ last; }

		my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$realmoto,$file);


				if($thread->{'sexvio'} >= 1 && $Age < 15){ next; }
				if($thread->{'sexvio'} >= 2 && $Age < 18){ next; }
				if($thread->{'keylevel'} >= 0.5){ $jump_no = $file; $flag = 1; last; }

	}


# ���_�C���N�g
if(!$flag){ Mebius::Redirect("","http://$server_domain/_$realmoto/",301); }
else{ Mebius::Redirect("","http://$server_domain/_$realmoto/$jump_no.html",301); }

exit;

}

1;
