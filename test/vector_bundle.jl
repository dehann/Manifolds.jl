include("utils.jl")

@testset "Tangent bundle" begin
    M = Sphere(2)

    @testset "FVector" begin
        tvs = ([1.0, 0.0, 0.0], [0.0, 1.0, 0.0])
        fv_tvs = map(v -> FVector(TangentSpace, v), tvs)
        fv1 = fv_tvs[1]
        tv1s = similar(fv_tvs[1])
        @test isa(tv1s, FVector)
        @test tv1s.type == TangentSpace
        @test size(tv1s.data) == size(tvs[1])
        @test eltype(tv1s) == eltype(tvs[1])
        @test isa(fv1 + fv1, FVector)
        @test (fv1 + fv1).type == TangentSpace
        @test isa(fv1 - fv1, FVector)
        @test (fv1 - fv1).type == TangentSpace
        @test isa(-fv1, FVector)
        @test (-fv1).type == TangentSpace
        @test isa(2*fv1, FVector)
        @test (2*fv1).type == TangentSpace
    end

    types = [Vector{Float64},
             SizedVector{3, Float64},
             MVector{3, Float64},
             Vector{Float32},
             SizedVector{3, Float32},
             MVector{3, Float32},
             Vector{Double64},
             MVector{3, Double64},
             SizedVector{3, Double64}]
    for T in types
        x = convert(T, [1.0, 0.0, 0.0])
        TB = TangentBundle(M)
        @test base_manifold(TB) == M
        @testset "Type $T" begin
            pts_tb = [ProductRepr(convert(T, [1.0, 0.0, 0.0]), convert(T, [0.0, -1.0, -1.0])),
                      ProductRepr(convert(T, [0.0, 1.0, 0.0]), convert(T, [2.0, 0.0, 1.0])),
                      ProductRepr(convert(T, [1.0, 0.0, 0.0]), convert(T, [0.0, 2.0, -1.0]))]
            @inferred ProductRepr(convert(T, [1.0, 0.0, 0.0]), convert(T, [0.0, -1.0, -1.0]))
            for pt ∈ pts_tb
                @test bundle_projection(TB, pt) ≈ pt.parts[1]
            end
            test_manifold(TB,
                          pts_tb,
                          test_reverse_diff = isa(T, Vector),
                          test_tangent_vector_broadcasting = false,
                          test_project_tangent = true)
        end
    end

    @test TangentBundle{Sphere{2}} == VectorBundle{Manifolds.TangentSpaceType, Sphere{2}}
    @test CotangentBundle{Sphere{2}} == VectorBundle{Manifolds.CotangentSpaceType, Sphere{2}}

    @test base_manifold(TangentBundle(M)) == M
    @testset "spaces at point" begin
        x = [1.0, 0.0, 0.0]
        t_x = TangentSpaceAtPoint(M, x)
        ct_x = CotangentSpaceAtPoint(M, x)
        @test base_manifold(t_x) == M
        @test base_manifold(ct_x) == M
        @test t_x.fiber.M == M
        @test ct_x.fiber.M == M
        @test t_x.fiber.VS == TangentSpace
        @test ct_x.fiber.VS == CotangentSpace
        @test t_x.x == x
        @test ct_x.x == x
    end

    @testset "tensor product" begin
        TT = Manifolds.TensorProductType(TangentSpace, TangentSpace)
        @test vector_space_dimension(VectorBundleFibers(TT, Sphere(2))) == 4
        @test vector_space_dimension(VectorBundleFibers(TT, Sphere(3))) == 9
    end

end
