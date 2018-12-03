let project = new Project('10Up Origins');

project.addSources('Sources');
project.addLibrary('Kha2D');
project.addAssets('Assets/data/*');
project.addAssets('Assets/sprites/*');
project.addAssets('Assets/fonts/*');

//project.addDefine('debug_collisions'); // TODO: remove for release

resolve(project);
