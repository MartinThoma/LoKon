{$ifdef full}
{$define undo}
{$define osc}
{$define elewin}
{$define ROMRAM}
{$define PLA}
{$define layele}
{$endif}

{$ifdef small}
{$define undo}
{$define osc}
{$undef elewin}
{$define ROMRAM}
{$define PLA}
{$undef layele}
{$endif}

{$ifdef mini}
{$define undo}
{$undef osc}
{$undef elewin}
{$undef ROMRAM}
{$undef PLA}
{$undef layele}
{$endif}
