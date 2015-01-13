require 'rubygems'
require 'RMagick'

module AndroidImgResizer
	 
   PREFIX = 'app/src/main/'

  MDPI = 'mdpi'
  HDPI = 'hdpi'
  XHDPI = 'xhdpi'
  XXHDPI = 'xxhdpi'

  SUFFIX = [MDPI, HDPI, XHDPI, XXHDPI]

  def self.verify_android_project
  	
  	directories = SUFFIX.map { |suffix| directory(suffix) }
  	
    directories.each do |directory|
      if  !File::directory?(directory)
        puts "Error: This is not a Android project Directory\n"
        puts "Error: Directory not exists #{directory} \n"
        return false
      end
    end
    return true
  end

  def self.list_images(base_dpi="xxhdpi")
    return if !self.verify_android_project
    Dir::chdir(directory(base_dpi))
    files=Dir["*.{png,jpg,gif,bitmap}"] 
    files.each do |entry|
      puts "Drawable File = #{entry}"
    end
  end

  def self.resize_all_images(base_dpi="xxhdpi")
    return if !self.verify_android_project

    baseline_path = directory(base_dpi)
    if !File::exists?(baseline_path)
      puts "Baseline path #{baseline_path} doesnt exist"
      exit(1)
    end

    Dir::chdir(baseline_path)
    files=Dir["*.{png,jpg,gif,bitmap}"]
    Dir::chdir("../../")
    files.each do |entry|      
      resize_image(entry,base_dpi)
    end
  end

  def self.scale(imageFile,rimg,factor,tag)
    xsize=rimg.columns*factor
    ysize=rimg.rows*factor
    puts "Image = #{imageFile} #{tag} = #{xsize.to_i}x#{ysize.to_i}"
    hdpi = rimg.scale(xsize.to_i,ysize.to_i)
    hdpi.write path(imageFile, tag)
  end

  def self.resize_image(imageFile,base_dpi="xxhdpi")
    return if !self.verify_android_project
    
    full_path = path(imageFile, base_dpi)
    
    if !File::exists?(full_path)
      puts "Image #{full_path} doesnt exist"
      exit(1) 
    end

    rimg = Magick::Image.read(full_path).first 
    puts "Resizing Image = #{imageFile} with size = #{rimg.columns}x#{rimg.rows} from #{base_dpi}"      
    
    # Scale Down images in res/drawable-xxxhdpi to the lower dpis
    if base_dpi == 'xxxhdpi'             
      self.scale_xxxhdpi(imageFile,rimg)    
    # Scale Down images in res/drawable-xxhdpi to the lower dpis      
    elsif base_dpi == 'xxhdpi' 
      self.scale_xxhdpi(imageFile,rimg)                
    # Scale Down images in res/drawable-xhdpi to the lower dpis            
    elsif base_dpi == 'xhdpi'
      self.scale_xhdpi(imageFile,rimg)
    # Scale Down images in res/drawable-hdpi to the lower dpis
    else     	    
      self.scale_hdpi(imageFile,rimg)     
    end      
   
  end 

  def self.scale_xxxhdpi(imageFile,rimg)
    # xxdpi version 3/4 - 3.0x mdpi
    self.scale(imageFile,rimg,0.75,"xxhdpi")
    # xxdpi version 2/4 - 2.0x mdpi      
    self.scale(imageFile,rimg,0.5,"xhdpi")
    # xxdpi version 1.5/4 - 1.5x mdpi      
    self.scale(imageFile,rimg,0.375,"hdpi")
    # xxdpi version 1/4 - 1.0x mdpi      
    self.scale(imageFile,rimg,0.25,"mdpi")  
  end

  def self.scale_xxhdpi(imageFile,rimg)
    # xdpi version 2/3 - 2.0x mdpi
    self.scale(imageFile,rimg,2.0/3,"xhdpi")
    # hdpi version 0.5 - 1.5x mdpi
    self.scale(imageFile,rimg,0.5,"hdpi")
    # hdpi version 1/3 - 1.0x mdpi      
    self.scale(imageFile,rimg,1.0/3,"mdpi")
  end

  def self.scale_xhdpi(imageFile,rimg)
    # xdpi version 0.75 - 1.5x mdpi
    self.scale(imageFile,rimg,0.75,"hdpi")
    # xdpi version 0.5 - 1.0x mdpi
    self.scale(imageFile,rimg,0.5,"mdpi")    
  end

  def self.scale_hdpi(imageFile,rimg)
    # xdpi version 2/3 - 1.5x mdpi
    self.scale(imageFile,rimg,2.0/3,"mdpi")   
  end

  def self.directory(suffix)
    "#{PREFIX}res/drawable-#{suffix}/"
  end

  def self.path(name, suffix)
    directory(suffix) + name
  end

  def self.clean_files(imgtoclean)

    SUFFIX.each do |suffix|
      file = path(imgtoclean, suffix)
      File.delete(file) if File.exists?(file)
    end

  end

end
