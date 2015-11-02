classdef TestKAZE
    %TestKAZE
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_compute_img
            obj = cv.KAZE('Extended',false, 'Upright',false);
            assert(obj.Extended == false);
            assert(obj.Upright == false);
            typename = obj.typeid();
            ntype = obj.defaultNorm();

            kpts = obj.detect(TestKAZE.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestKAZE.kfields, fieldnames(kpts))));

            [desc, kpts2] = obj.compute(TestKAZE.img, kpts);
            validateattributes(kpts2, {'struct'}, {'vector'});
            assert(all(ismember(TestKAZE.kfields, fieldnames(kpts2))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts2) obj.descriptorSize()]});
        end

        function test_detect_compute_imgset
            imgs = {TestKAZE.img, TestKAZE.img};
            obj = cv.KAZE();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestKAZE.kfields, fieldnames(kpt)))), kpts);

            [descs, kpts] = obj.compute(imgs, kpts);
            validateattributes(descs, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(d,k) validateattributes(d, {obj.descriptorType()}, ...
                {'size',[numel(k) obj.descriptorSize()]}), descs, kpts);
        end

        function test_detectAndCompute
            obj = cv.KAZE();
            [kpts, desc] = obj.detectAndCompute(TestKAZE.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestKAZE.kfields, fieldnames(kpts))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts) obj.descriptorSize()]});
        end

        function test_detectAndCompute_providedKeypoints
            obj = cv.KAZE();
            kpts = obj.detect(TestKAZE.img);

            kpts = kpts(1:min(20,end));
            [~, desc] = obj.detectAndCompute(TestKAZE.img, 'Keypoints',kpts);
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts) obj.descriptorSize()]});
        end

        function test_detect_mask
            mask = zeros(size(TestKAZE.img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.KAZE();
            kpts = obj.detect(TestKAZE.img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestKAZE.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(TestKAZE.img,2)/2)));
        end

        function test_error_1
            try
                cv.KAZE('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
