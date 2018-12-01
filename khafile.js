let project = new Project('10Up Origins');

project.addSources('Sources');
project.addLibrary('Kha2D');
project.addAssets('Assets/data/*');
project.addAssets('Assets/sprites/*');

resolve(project);
