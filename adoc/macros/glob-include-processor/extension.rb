class GlobIncludeProcessor < Asciidoctor::Extensions::IncludeProcessor

  def handles? target
    # Gère les fichiers dont le nom contient un * ou le dossier /modules/
    target.include? '*' or target.include? '/modules/'
  end

  def process doc, reader, target_glob, attributes
    if attributes.has_key? 'saisons-option'
      process_pages(reader, target_glob, attributes, "saison")

    elsif attributes.has_key? 'episodes-option'
      process_pages(reader, target_glob, attributes, "episode")
      
    elsif attributes.has_key? 'episodes-overview-option'
      process_pages(reader, target_glob, attributes, "episode-overview")

    elsif attributes.has_key? 'breadcrumb-option'
      process_breadcrumb(reader, target_glob, attributes)

    elsif attributes.has_key? 'modules-option'
      process_modules(reader, target_glob, attributes)

    elsif attributes.has_key? 'suivi-option'
      process_modules(reader, target_glob, attributes)

    elsif attributes.has_key? 'modules-toc-option'
      process_modules_toc(reader, target_glob, attributes)

    elsif attributes.has_key? 'pdf-option'
      process_pdf(reader, target_glob, attributes)

    else
      process_include(reader, target_glob, attributes)
    end
  end

  def extract_var(content, var)
    content.each_with_index do |line, index|
      if line.start_with?(":#{var}:")
        return line.strip.sub(":#{var}:", '')
      end
    end
    ''
  end

  def extract_directory_path(file_path, pattern)
    regex = Regexp.new(pattern.gsub('*', '([^/]+)'))
    match = file_path.match(regex)
    match[1] if match
  end



  # GESTION DES INCLUDES CLASSIQUES
  def process_include(reader, target_glob, attributes)

    # Pour chaque fichier correspondant au motif
    Dir[File.join reader.dir, target_glob].sort.reverse_each do |target|
      filename = File.basename(target).sub('.adoc', '')
      folder = target.split('./')[1].split("#{filename}")[0]

      # Récupère le contenu du fichier
      content = IO.readlines target
      content.unshift ''
      
      # Crée un lien vers le fichier
      title = extract_var(content, 'titre')
      path = "./#{folder}index.html"
      link = "link:++#{path}++[#{title}]"
      
      # Ajoute le contenu du fichier avec le lien et le premier titre
      reader.push_include("Lien vers #{link}\n\n", '', target, 1, {})
      reader.push_include(content, target, target, 1, attributes)
    end

  end

  # GESTION DES MODULES
  def process_modules(reader, target_glob, attributes)
    # Pour chaque fichier correspondant au motif
    Dir[File.join reader.dir, target_glob].sort.reverse_each do |target|
      filename = File.basename(target).sub('.adoc', '')
      folder = target.split('../modules/')[-1].split("/#{filename}")[0]
      dirname = File.expand_path(File.dirname(File.dirname(target))).split('/sources/')[1]
      path = "#{dirname}/#{folder}/#{filename}"

      # Récupère le contenu du fichier
      content = IO.readlines target
      content.unshift ''

      # Crée un lien vers le fichier
      title = extract_var(content, 'titre')
      duration = extract_var(content, 'duree')
      description = extract_var(content, 'description')

      # Compte le nombre de lignes demo et exercie
      demo = content.select { |line| line.start_with?("// tag::demo[]") }.count
      exercice = content.select { |line| line.start_with?("// tag::exercice[]") }.count

      # Récupère le contenu du fichier d'introduction
      content = IO.readlines "/workspace/adoc/libs/intro-module.adoc"
      content.unshift ''
      
      # Ajoute le contenu du fichier
      reader.push_include(content, target, target, 1, attributes)
      reader.push_include("\n\n:path: #{path}\n", '', target, 1, {})
      reader.push_include("\n\n:folder: #{folder.upcase}\n", '', target, 1, {})
      reader.push_include("\n\n:filename: #{filename}\n", '', target, 1, {})
      reader.push_include("\n\n:title: #{title}\n", '', target, 1, {})
      reader.push_include("\n\n:duration: #{duration}\n", '', target, 1, {})
      reader.push_include("\n\n:description: #{description}\n", '', target, 1, {})
      reader.push_include("\n\n:demo: #{demo}\n", '', target, 1, {})
      reader.push_include("\n\n:exercice: #{exercice}\n", '', target, 1, {})
    end
  end
  
  def process_modules_toc(reader, target_glob, attributes)
    # Pour chaque dossier correspondant au motif
    Dir[File.join reader.dir, target_glob].sort.reverse_each do |target|
      # Uniquement les dossiers
      next unless File.directory? target
      folder = target.split('/modules/./')[-1]

      # Pour chaque fichier du .adoc du dossier
      Dir[File.join target, '*.adoc'].sort.reverse_each do |file|
        # Récupère le contenu du fichier principal
        content = IO.readlines file
        # Extrait les variables
        title = extract_var(content, 'titre')

        filename = File.basename(file).sub('.adoc', '')
        path = "./#{folder}/#{filename}.html"
        link = "link:++#{path}++[#{title}]"
        
        reader.push_include("* #{link}\n", '', target, 1, {})
      end
      
      reader.push_include("\n== #{folder.upcase}\n\n", '', target, 1, {})
    end
  end


  # GENERATION DU PDF PAR SAISON
  def process_pdf(reader, target_glob, attributes)
    # Pour chaque fichier correspondant au motif
    Dir[File.join reader.dir, target_glob].sort.reverse_each do |target|
      # Récupère le contenu du fichier
      content = IO.readlines target

      # Pour chaque ligne
      content.reverse_each do |line|
        # Si la ligne contient [options=modules] and don't start with //
        if (line.include? '[options=modules]' and !line.start_with? '//')
          # Supprime [options=modules]
          line = line.sub('.adoc[options=modules]', '')
          # Supprime include::../../../../
          line = line.sub('include::../../../../', '')
          line = line.strip
          
          folder = line.split('/')[1]
          dirname = File.expand_path(File.dirname(File.dirname(target))).split('/saisons/')[0]
          file = "sources/#{dirname.split('/sources/')[1]}/#{line}.adoc"

          # Lit le contenu du fichier
          contentfile = IO.readlines file

          reader.push_include(contentfile, nil, nil, 1, attributes)
          reader.push_include("\n\n:imagesdir: #{dirname}/modules/#{folder}\n")
        end
      end
    end

    reader.process_lines()
  end


  # GESTION DES PAGES
  def process_pages(reader, target_glob, attributes, type) 
    # Pour chaque fichier correspondant au motif
    Dir[File.join reader.dir, target_glob].sort.reverse_each do |target|
      # Récupère le nom du dossier dynamiquement
      number = extract_directory_path(target, target_glob)

      # Récupère le contenu du fichier principal
      content = IO.readlines target
      # Extrait les variables
      title = extract_var(content, 'title')
      duration = extract_var(content, 'duration')

      # Récupère le contenu du fichier d'introduction
      content = IO.readlines "/workspace/adoc/libs/intro-#{type}.adoc"
      content.unshift ''

      # Ajoute le contenu du fichier
      reader.push_include(content, target, target, 1, attributes)
      reader.push_include("\n\n:number: #{number}\n", '', target, 1, {})
      reader.push_include("\n\n:title: #{title}\n", '', target, 1, {})
      reader.push_include("\n\n:duration: #{duration}\n", '', target, 1, {})
    end
  end
  
  
  #GESTION DU FIL D'ARIANE
  def process_breadcrumb(reader, target_glob, attributes)

    path = target_glob.split("/sources/")[1]
    parent = "/"
    
    # If path not nil
    if path
      breadcrumb = "[.breadcrumb]\nlink:/[Accueil] > "
      path = path.split("/")
      path.pop()

      path.each do |folder|
        name = folder.sub(folder[0], folder[0].upcase)

        # Si le fichier existe
        if File.exist?("/workspace/sources/#{parent}#{folder}/index.adoc")
          breadcrumb = "#{breadcrumb}link:#{parent}#{folder}/[#{name}] > "
        else
          breadcrumb = "#{breadcrumb}#{name} > "
        end

        parent = "#{parent}#{folder}/"
      end
    else
      breadcrumb = "link:/[Accueil]"
    end

    reader.push_include("#{breadcrumb}")
  end
end