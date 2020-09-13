program makenewdata
implicit none
   !指定した時間での平均風速と標準偏差データを作成するプログラム。前n秒平均風。 
   integer :: switch
   integer,parameter :: datamax=86400,jmax=123  !1秒毎のデータ数(固定!)、地点数
   integer :: hour(datamax),minute(datamax),second(datamax),dir(datamax),i,j,k,imax,fix
   real :: wind(datamax),averagewind(datamax),averagedir(datamax),sum,devsq,stdev(datamax)
   logical :: calm(datamax)  !平均時間中静穏だったかどうか
   character(len=80) :: first
   character(len=160) :: datafile1,datafile2,datafile3
   character(len=5) :: alpha  !ファイル名に付ける時間の部分
   character(len=3) :: number
   character(len=8) :: date="20170809"

   write(*,*)"平均を取りたい秒数を入力してください。"
   read(*,*)switch
   
   if(switch==1)then
      imax=86400
      fix=1
      alpha="1sec"
   endif
   if(switch==3)then
      imax=28800
      fix=3
      alpha="3sec"
   endif
   if(switch==60)then
      imax=1440
      fix=60
      alpha="1min"
   endif
   if(switch==600)then
      imax=144
      fix=600
      alpha="10min"
   endif
   if(switch/=1 .and. switch/=3 .and. switch/=60 .and. switch/=600)then
      write(*,*)"その秒数は対応していません。"
      imax=86400/switch
      fix=switch
      write(*,*)"先程の秒数を英語で入力。(例：180秒の時は3min) alpha"
      read(*,*)alpha
   endif

   !番号管理とファイル名
   do j=1,jmax
      if(1<=j .and. j<=9)then
         write(number,'(a2,i1)')'00',j
      endif
      if(10<=j .and. j<=99)then
         write(number,'(a1,i2)')'0',j
      endif
      if(100<=j .and. j<=123)then
         write(number,'(i3)')j
      endif
      datafile1='/work42/username/2017_0809_gust-tornado/Maeda_Winds/org_data/wind/Second_'//date//'_'//number//'_1.csv'
      datafile2='/work42/username/2017_0809_gust-tornado/Maeda_Winds/org_data/wind/Second_'//date//'_'//number//'_2.csv'     
      datafile3='/work42/username/2017_0809_gust-tornado/Maeda_Winds/produce/'//trim(alpha)//'/mean_'//trim(alpha)//'_data_20170809_'//number//'.txt'      

      open(10,file=datafile1,status='old')
      open(11,file=datafile2,status='old')
      open(20,file=datafile3,status='unknown')

      !最初の行の無駄な文字列を読み込む
      read(10,*)first
      read(11,*)first
      
      !午前のデータ読み込み
      do i=1,datamax*0.5
         read(10,*)hour(i),minute(i),second(i),wind(i),dir(i)
!         call lostdata(wind(i),dir(i))
         calm(i)=.false.
         !静穏の時の風向処理(0にする)
         if(0.0<=wind(i) .and. wind(i)<0.3)then
            dir(i)=0
            calm(i)=.true.
         endif
         !欠損値管理
         if((dir(i)<=0 .and. calm(i)==.false.) .or. wind(i)<0.0)then
            dir(i)=99
         endif
         if(wind(i)<0.0)then
            wind(i)=-99.9
         endif
      enddo

      !午後のデータ読み込み
      do i=datamax*0.5+1,datamax
         read(11,*)hour(i),minute(i),second(i),wind(i),dir(i)
         calm(i)=.false.
         !静穏の時の風向処理(0にする)
         if(0.0<=wind(i) .and. wind(i)<0.3)then
            dir(i)=0
            calm(i)=.true.
         endif
         !欠損値管理
         if((dir(i)<=0 .and. calm(i)==.false.) .or. wind(i)<0.0)then
            dir(i)=99
         endif
         if(wind(i)<0.0)then
            wind(i)=-99.9
         endif
      enddo
      
      !平均風速
      if(switch/=1)then
         do i=1,imax
            sum=0.0
            averagewind(i)=0.0
            do k=1,fix
               if(wind((i-1)*fix+k) == -99.9)then
                  averagewind(i)=-99.9
                  exit
               endif
               sum=sum+wind((i-1)*fix+k)
            enddo
            if(averagewind(i)/=-99.9)then
               averagewind(i)=sum/(fix*1.0)
            endif
         enddo
      endif

      !平均風向(風速(ベクトルの長さ)は関係なしで風向だけを平均)
      if(switch/=1)then
         do i=1,imax
            sum=0.0
            averagedir(i)=0.0
            calm(i)=.false.
            do k=1,fix
               !欠損値が1つでもあったら平均も欠損値扱い
               if(dir((i-1)*fix+k)==99)then
                  averagedir(i)=-99.9
                  exit
               endif

               if(sum==0.0)then
                  sum=sum+dir((i-1)*fix+k)
                  
                  !北風をまたぐかどうかで処理が異なる
               else if(sum/real(k)<8.0)then
                  if(8.0<dir((i-1)*fix+k))then
                     sum=sum+dir((i-1)*fix+k)-16
                  else
                     sum=sum+dir((i-1)*fix+k)
                  endif
                  
               else if(8.0<sum/real(k))then
                  if(dir((i-1)*fix+k)<8.0)then
                     sum=sum+dir((i-1)*fix+k)+16
                  else
                     sum=sum+dir((i-1)*fix+k)
                  endif
                  
               endif
               !北風が0とされた時、静穏と区別がつかないため、その判別処理
               if(dir((i-1)*fix+k)==0 .and. calm(i)==.false.)then
                  calm(i)=.true.
               endif
               if(dir((i-1)*fix+k)/=0 .and. calm(i)==.true.)then
                  calm(i)=.false.
               endif
            enddo

            if(averagedir(i)/=-99.9)then
               if(calm(i)==.true.)then
                  averagedir(i)=0.0
               else
                  averagedir(i)=sum/(fix*1.0)
               endif
            endif
            
            if(averagedir(i)<0.0 .and. averagedir(i)/=-99.9)then
               averagedir(i)=averagedir(i)+16
            else if(averagedir(i)>16.0)then
               averagedir(i)=averagedir(i)-16
            endif

            if(averagewind(i)==0.0 .and. averagedir(i)==0.0)then
               averagewind(i)=-99.9
               averagedir(i)=-99.9
            else if(averagewind(i)/=0.0 .and. averagedir(i)==0)then
                  averagedir(i)=16.0
            endif
         enddo
      endif
      
      !標準偏差
      if(switch/=1)then
         do i=1,imax
            devsq=0.0
            stdev(i)=0.0
            do k=1,fix
               if(wind((i-1)*fix+k)==-99.9)then
                  stdev(i)=-99.9
                  exit
               endif
               devsq=devsq+(wind((i-1)*fix+k)-averagewind(i))**2
            enddo
            if(stdev(i)/=-99.9)then
               stdev(i)=sqrt(devsq/(fix*1.0))
            endif
            if(averagewind(i)==-99.9 .and. averagedir(i)==-99.9)then
               stdev(i)=-99.9
            endif
         enddo
      endif

      !60秒補正
      do i=1,imax
         if(second(i*fix)==60)then
            if(minute(i*fix)==59)then
               hour(i*fix)=hour(i*fix)+1
               minute(i*fix)=0
               second(i*fix)=0
            else
               minute(i*fix)=minute(i*fix)+1
               second(i*fix)=0
            endif
         endif
      enddo

      !書き込み
      do i=1,imax
         if(switch==1)then
            write(20,100)hour(i),minute(i),second(i),wind(i),dir(i)   !1秒毎
            !write(*,100)hour(i),minute(i),second(i),wind(i),dir(i)
         else
            write(20,101)hour(i*fix),minute(i*fix),second(i*fix),averagewind(i),stdev(i),averagedir(i)  !平均と標準偏差と風向あり
!            write(*,101)hour(i*fix),minute(i*fix),second(i*fix),averagewind(i),stdev(i),averagedir(i)  !平均と標準偏差と風向あり
         endif
      enddo
      write(*,'(a110,1x,a12)')datafile3,'was written.'
      write(*,*)
      close(10)
      close(11)
      close(20)
   enddo

100 format(i2,1x,i2,1x,i2,1x,f8.3,1x,i2)
101 format(i2,1x,i2,1x,i2,1x,f8.3,1x,f8.3,1x,f5.1)

!function lostdata(w(i),d(i))
!         calm(i)=.false.
         !静穏の時の風向処理(0にする)
!         if(0.0<=wind(i) .and. wind(i)<0.3)then
!            dir(i)=0
!            calm(i)=.true.
!         endif
         !欠損値管理
!         if((dir(i)<=0 .and. calm(i)==.false.) .or. wind(i)<0.0)then
!            dir(i)=99
!         endif
!         if(wind(i)<0.0)then
!            wind(i)=-99.9
!         endif
!end function lostdata

end program
