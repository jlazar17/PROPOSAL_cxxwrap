using Test
using CxxWrap
using Libdl

# Determine library path: env var override (CI builds from source) or JLL
const libpath = if haskey(ENV, "LIBPROPOSAL_CXXWRAP_PATH")
    ENV["LIBPROPOSAL_CXXWRAP_PATH"]
else
    using PROPOSAL_cxxwrap_jll
    PROPOSAL_cxxwrap_jll.libPROPOSAL_cxxwrap_path
end

# --------------------------------------------------------------------------- #
# Module loading — this alone catches the SetWeakPartner / factory-error class
# --------------------------------------------------------------------------- #
module PROPOSALLib
    using CxxWrap
    using Libdl
    const _path = Main.libpath
    @wrapmodule(() -> _path, :define_julia_module, Libdl.RTLD_LAZY | Libdl.RTLD_GLOBAL)
    function __init__()
        @initcxx
    end
end

@testset "PROPOSAL_cxxwrap" begin

    @testset "Module loads" begin
        @test isdefined(PROPOSALLib, :MuMinusDef)
        @test isdefined(PROPOSALLib, :Cartesian3D)
        @test isdefined(PROPOSALLib, :Medium)
    end

    # ------------------------------------------------------------------ #
    # Type instantiation — verifies all CxxWrap type registrations work
    # ------------------------------------------------------------------ #
    @testset "ParticleDef subtypes" begin
        for T in [
            PROPOSALLib.MuMinusDef, PROPOSALLib.MuPlusDef,
            PROPOSALLib.EMinusDef, PROPOSALLib.EPlusDef,
            PROPOSALLib.TauMinusDef, PROPOSALLib.TauPlusDef,
            PROPOSALLib.GammaDef,
            PROPOSALLib.Pi0Def, PROPOSALLib.PiMinusDef, PROPOSALLib.PiPlusDef,
            PROPOSALLib.K0Def, PROPOSALLib.KMinusDef, PROPOSALLib.KPlusDef,
        ]
            p = T()
            @test p isa PROPOSALLib.ParticleDef
        end
    end

    @testset "Medium creation" begin
        water = PROPOSALLib.create_water()
        @test water isa PROPOSALLib.Medium
        @test PROPOSALLib.get_mass_density(water) > 0.0

        ice = PROPOSALLib.create_ice()
        @test ice isa PROPOSALLib.Medium

        air = PROPOSALLib.create_air()
        @test air isa PROPOSALLib.Medium
    end

    @testset "Geometry types" begin
        origin = PROPOSALLib.Cartesian3D(0.0, 0.0, 0.0)
        sphere = PROPOSALLib.Sphere(origin, 1e5)
        @test sphere isa PROPOSALLib.Geometry

        cyl = PROPOSALLib.Cylinder(origin, 1e5, 0.0, 1e5)
        @test cyl isa PROPOSALLib.Geometry

        box = PROPOSALLib.Box(origin, 1e5, 1e5, 1e5)
        @test box isa PROPOSALLib.Geometry
    end

    @testset "Component types" begin
        h = PROPOSALLib.ComponentHydrogen()
        @test h isa PROPOSALLib.Component
        @test PROPOSALLib.get_nuc_charge(h) == 1.0

        fe = PROPOSALLib.ComponentIron()
        @test fe isa PROPOSALLib.Component
        @test PROPOSALLib.get_nuc_charge(fe) == 26.0
    end

    @testset "Vector3D operations" begin
        v = PROPOSALLib.Cartesian3D(1.0, 2.0, 3.0)
        @test PROPOSALLib.get_x(v) ≈ 1.0
        @test PROPOSALLib.get_y(v) ≈ 2.0
        @test PROPOSALLib.get_z(v) ≈ 3.0
    end

    @testset "EnergyCutSettings" begin
        cuts = PROPOSALLib.EnergyCutSettings(500.0, 0.05, false)
        @test PROPOSALLib.get_ecut(cuts) ≈ 500.0
        @test PROPOSALLib.get_vcut(cuts) ≈ 0.05
    end

    @testset "Constants" begin
        @test PROPOSALLib.ELECTRON_MASS > 0.0
        @test PROPOSALLib.MUON_MASS > PROPOSALLib.ELECTRON_MASS
        @test PROPOSALLib.SPEED_OF_LIGHT > 0.0
    end

    @testset "Utility functions" begin
        ver = PROPOSALLib.get_proposal_version()
        @test ver isa String
        @test length(ver) > 0

        PROPOSALLib.set_random_seed(42)
        r = PROPOSALLib.random_double()
        @test 0.0 <= r <= 1.0
    end

end
